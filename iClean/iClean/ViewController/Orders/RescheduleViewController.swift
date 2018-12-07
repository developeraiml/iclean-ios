//
//  RescheduleViewController.swift
//  iClean
//
//  Created by Anand on 05/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class RescheduleViewController: BaseViewController {

    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var rescheduleBtn: UIButton!
    
    var driverNotes : String?
    var orderId : String = ""
    
    var isPickMessage: Bool = true
    
    var showOnlyCancel : Bool = false
    
    var rescheduleHandler : ((Bool)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        notesTextView.text = driverNotes
        
        if isPickMessage == false {
            self.cancelBtn.isHidden = true
        }
        
        if showOnlyCancel == true {
            self.rescheduleBtn.isHidden = true
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        showLoadSpinner(message: "Cancelling Order ...")
        
        let api = OrderNetworkModel()
        api.deleteOrder(orderId: orderId) { (success, response, error) in
            
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
                        strongSelf.navigationController?.popViewController(animated: true)
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                    }
                    
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                }
            })
        }
    }
    
    @IBAction func rescheduleAction(_ sender: Any) {
        
        if let handler = rescheduleHandler {
            handler(true)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
