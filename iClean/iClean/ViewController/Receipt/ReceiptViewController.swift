//
//  ReceiptViewController.swift
//  iClean
//
//  Created by Anand on 04/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class ReceiptViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableview: UITableView!
    var itemCount: CGFloat = 0
    
    fileprivate let numberFormatter = NumberFormatter()
    fileprivate var totalOrderCost : Double = 0.0
    
    var orderDetails: order?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        itemCount = CGFloat(orderDetails?.items.count ?? 0)
        
        //totalOrderCost = (self.orderDetails?.items.reduce(0, { $0 + ($1.totalAmount ?? 0.0)}) ?? 0.0)
        
      //  orderDetails?.orderCost = totalOrderCost
        
        totalOrderCost = orderDetails?.orderCost ?? 0.0
        
        self.tableview.reloadData()
    }
    

    
    @IBAction func doneAction(_ sender: Any) {
        submitPayment()
    }
    
    fileprivate func submitPayment() {
        
        let api = OrderNetworkModel()
        
        let orderCost = orderDetails?.orderCost ?? 0.0
        let tipAmount = orderDetails?.tipAmount ?? 0.0
        
        let dict = ["tip_amount" : tipAmount,
            "amount" : orderCost,
            "total" : orderCost + tipAmount,
            "is_payment_made" : true ] as [String : AnyObject]
        
        showLoadSpinner(message: "Submit Payment ...")
        api.updateOrder(dict, orderDetails?.uid ?? "0") { (success, response, error) in
            
            //debugPrint(response)
            
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
                        
                    } else if response?["status"] as? Int == 200 {
                        
                        strongSelf.presentAlert(title: nil, message: "Payment made successfully", completion: { (status) in
                            
                            let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "WriteReviewViewController") as? WriteReviewViewController
                            vc?.orderDetails = strongSelf.orderDetails
                            strongSelf.navigationController?.pushViewController(vc!, animated: true)
                        })
                        
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                    
                }
            })
        }
    }
    
    
    fileprivate func openTipScreen() {
        
        DispatchQueue.main.async {
            let tipVC = self.storyboard?.instantiateViewController(withIdentifier: "TipsViewController") as? TipsViewController
            
            tipVC?.willMove(toParent: self)
            self.view.addSubview(tipVC!.view)
            self.addChild(tipVC!)
            tipVC!.didMove(toParent: self)
            
            tipVC?.totalAmount = self.totalOrderCost
            
            tipVC?.tipAddHandler = { [weak self] tipAmount in
                
                let number = self?.numberFormatter.number(from: tipAmount)
                self?.orderDetails?.tipAmount = number?.doubleValue
                
                self?.tableview.reloadData()
            }
        }
      
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 2 : 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailsReceiptCell") as? OrderDetailsCell
            
            cell?.pickTypeLbl.text = (indexPath.row == 0) ? "PICK UP" : "DROP OFF"
            cell?.pickDate.text = ((indexPath.row == 0) ? orderDetails?.pickupDate ?? "" :
                orderDetails?.dropOffDate ?? "")
            
            if let address = ((indexPath.row == 0) ? orderDetails?.pickupLocation : orderDetails?.dropOffLocation) {
                cell?.pickAddress.text = "\(address.address_1 ?? ""), \(address.apartment_name ?? ""), \(address.gate_code ?? ""), \(address.city ?? ""), \(address.state ?? "") \(address.zip_code ?? "")"
            }
           
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderReceiptCell") as? OrderReceiptCell
            cell?.totalAmount = orderDetails?.orderCost ?? 0.0
            cell?.discount = orderDetails?.discount ?? 0.0
            cell?.itemList = orderDetails?.items ?? []
            cell?.tipAmount = "\(orderDetails?.tipAmount ?? 0.0)"
            cell?.cardInfo = orderDetails?.cardInfo

            cell?.tipHandler = { [weak self] status in
                self?.openTipScreen()
            }
            return cell!
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 105 : (125 + ((itemCount + 1) * 50.0)) //Extra one add to calculate the tip cell
    }
    
}
