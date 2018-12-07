//
//  DriverLoginViewController.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class DriverLoginViewController: BaseViewController {
    
    @IBOutlet weak var emailTextField: RaisePlaceholder!
    @IBOutlet weak var passwordTextField: RaisePlaceholder!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func loginAction(_ sender: Any?) {
        
        self.view.endEditing(true)
        
        guard let email = emailTextField.text?.trimWhiteSpace(), let pass = passwordTextField.text?.trimWhiteSpace(), !email.isEmpty, !pass.isEmpty, email.isEmail else {
            //Throw error
            presentAlert(title: nil, message: "Invalid Email or Password")
            return
        }
        
        let deviceType = "1" //iOS
        let deviceUdid =  UIDevice.current.identifierForVendor?.uuidString
        let deviceToken = (UIApplication.shared.delegate as? AppDelegate)!.devicePushNotificationToken
        
        showLoadSpinner(message: "Signin ...")
        
        let param = ["email": email, "password": pass, "device_type": deviceType, "device_id": deviceUdid, "device_token": deviceToken]
        
        let loginAPi = DriverNetworkModel()
        loginAPi.performDriverSignIn(param: param as [String : AnyObject]) { [weak self](success, response, error) in
            
            debugPrint(response)
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                if success {
                    
                    let message = response?["message"] as? String
                    
                    if response?["status"] as? Int == 200 {
                        
                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            if let userToken = innerData["token"] as? String, let userId = innerData["driver_id"] as? String {
                                UserDefaults.standard.set(userToken, forKey: "userToken")
                                UserDefaults.standard.set(userId, forKey: "driverUserId")

                                UserDefaults.standard.synchronize()
                                
                                (UIApplication.shared.delegate as? AppDelegate)?.switchToDriverDashboard()
                            }
                            
                        }
                        
                    } else {
                        //error
                        strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                        
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                    
                }
                
            })
        
        }
    }

}


extension DriverLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.loginAction(nil)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        
        if let textfield = textField as? RaisePlaceholder {
            textfield.textFieldDidEditinfBegin()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textfield = textField as? RaisePlaceholder {
            textfield.textFieldDidEditingEnded()
        }
    }
}
