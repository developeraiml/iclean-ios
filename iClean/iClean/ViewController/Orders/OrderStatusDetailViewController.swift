//
//  OrderStatusDetailVC.swift
//  iClean
//
//  Created by Anand on 04/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderStatusDetailViewController: BaseViewController {

    enum tableviewType: Int {
        case both
        case dropOnly
        case pickupOnly
    }
    @IBOutlet weak var tableview: UITableView!
    
    fileprivate var tableType : tableviewType = .both
    
    @IBOutlet weak var cancelOrderBtn: UIButton!
    var orderStatus : order?
    var isRescheduled : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableview.tableFooterView = UIView()
        
        tableType = orderStatus?.ordStatus != .OrderPlaced ? .dropOnly : .both
        
        cancelOrderBtn.isHidden = tableType == .both ? false : true
        
    }
    
    @IBAction func cancelOrderAction(_ sender: Any) {
        
        showPopViewWithText { [weak self] (status) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.deleteOrder()
            })
        }
    }
    
    fileprivate func deleteOrder() {
        
        showLoadSpinner(message: "Deleting Order ...")

        let api = OrderNetworkModel()
        api.deleteOrder(orderId: (orderStatus?.uid)!) { (success, response, error) in
            
           // debugPrint(response)
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                
                if success {
                    
                    let message = response?["message"] as? String
                    
                    if response?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            
                            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                appDel.switchToLogin()
                            }
                        })
                        
                    } else if response?["status"] as? Int == 204 {
                        strongSelf.navigationController?.popToRootViewController(animated: true)
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                    }
                    
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                }
            })
        }
    }
}

extension OrderStatusDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.orderDetailCell) as? OrderDetailsCell
        
        cell?.pickTypeLbl.text = (indexPath.row == 0) ? "PICK UP" : "DROP OFF"
        cell?.pickDate.text = "Date: " + ((indexPath.row == 0) ? orderStatus?.pickupDate ?? "" : orderStatus?.dropOffDate ?? "")
        
        if let address = ((indexPath.row == 0) ? orderStatus?.pickupLocation : orderStatus?.dropOffLocation) {
            cell?.pickAddress.text = "\(address.address_1 ?? ""), \(address.apartment_name ?? ""), \(address.gate_code ?? ""), \(address.city ?? ""), \(address.state ?? "") \(address.zip_code ?? "")".capitalized
        }

        cell?.editButton.isEnabled = true
        if indexPath.row == 0 {
             cell?.editButton.isEnabled = (orderStatus?.ordStatus == .OrderPlaced) ? true : false
        }
       
        cell?.editButton.tag = indexPath.row
        cell?.editButton.addTarget(self, action: #selector(editPick_DropInfo), for: .touchUpInside)
        return cell!
    }
}

extension OrderStatusDetailViewController {
    
    @objc func editPick_DropInfo(sender : UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.orderUpdateVC) as? OrderUpdateViewController
        
        vc?.editPickInfo = sender.tag == 0 ? true : false
        vc?.pickObj = orderStatus
        vc?.isRescheduled = self.isRescheduled
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
