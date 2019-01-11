//
//  OrderConfirmationVC.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit
import Firebase


class OrderConfirmationViewController: BaseViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet private weak var confirmBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    
    var param : [String: AnyObject]?
    var orderObject : newOrder?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableview.tableFooterView = UIView()
    }
    
    
    @IBAction func confrimAction(_ sender: Any) {
        
        if let _ = param?["card_id"] {
            
            confirmBtn.isEnabled = false
            confirmBtn.alpha = 0.5
            
            placeOrder()
        }
        else {
            openCardlist()
        }
        
    }
    
    fileprivate func openCardlist() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.cardListVC) as? CardListViewController
        vc?.isViewPresented = true
        vc?.selectHandler = { [weak self] cardId in

        DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.confirmBtn.isEnabled = false
                strongSelf.confirmBtn.alpha = 0.5
                strongSelf.param?["card_id"] = cardId as AnyObject
                strongSelf.placeOrder()
            })
            
        }
        
        self.navigationController?.present(vc!, animated: true, completion: nil)
    }
    
    fileprivate func placeOrder() {
        
        showLoadSpinner(message: "Placing Order ...")
        
        //Analytics.logEvent("Place_order", parameters: param)
        
        let api = OrderNetworkModel()
        api.palceOrder(param!) { [weak self] (success, response, error) in
                        
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                
                strongSelf.confirmBtn.isEnabled = true
                strongSelf.confirmBtn.alpha = 1.0
                
                if success {

                    let message = response?["message"] as? String
                    if response?["status"] as? Int == 401 {
                        
                        Analytics.logEvent("Order_Status", parameters: (["Order_Res": "failed"]))


                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                appDel.switchToLogin()
                            }
                        })
                        
                    } else if response?["status"] as? Int == 201 {
                        
                        Analytics.logEvent("Order_Status", parameters: (["Order_Res": "Success"]))


                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            let ord = order(with: innerData)
                            strongSelf.showOrderStatus(ordDetails: ord)
                        }
                    } else {
                        
                        Analytics.logEvent("Order_Status", parameters: (["Order_Res": "server or Api thrown error"]))

                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            if let err = innerData["errors"] as? [AnyObject] {
                                strongSelf.presentAlert(title: nil, message: err.description )
                            }
                        } else {
                            strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                        }

                    }
                    
                } else {
                    
                    Analytics.logEvent("Order_Status", parameters: (["Order_Res": "Network error"]))


                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")

                }
                
            })
        }
    }
    
    fileprivate func showOrderStatus(ordDetails : order){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // your code here
            let vc = self.storyboard?.instantiateViewController(withIdentifier: GeneralConstants.orderStatusVC) as? OrderStatusViewController
            vc?.orderDetails = ordDetails
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
  
}


extension OrderConfirmationViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.orderConfirmationCel) as? OrderConfirmationCell
            
            let wash = orderObject?.washSetting
            cell?.washType.text = wash?.washType
            cell?.washNotes.text = wash?.washNotes!.count != 0 ? wash?.washNotes : "You have not added any notes for wash."
            return cell!
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.orderPickupConfirmationCell) as? OrderConfirmationPickupCell
            
            let order = orderObject?.pickupList[indexPath.row]
            
            cell?.pickupLbl.text = indexPath.row == 0 ? "PICK UP" : "DROP OFF"
            
            cell?.locationLabel.text = order?.selectedAddress
            cell?.dateLabel.text = order?.selectedDate
            cell?.timeLabel.text = order?.selectedTime
            
            cell?.driverInstLbl.text = order?.instruction?.count != 0 ?  order?.instruction : "No instruction are added to driver."
            
            return cell!
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

}
