//
//  LoginViewController.swift
//  iClean
//
//  Created by Anand on 16/09/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit


class LoginViewController: LoginBaseViewController {
    
    @IBOutlet weak var emailTextField: RaisePlaceholder!
    @IBOutlet weak var passwordTextField: RaisePlaceholder!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !iCleanManager.sharedInstance.isBrainTreeTokenAvailable() {
            iCleanManager.sharedInstance.fetchBrainTreeToken()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func showDriveLogin(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            let vc = storyboard?.instantiateViewController(withIdentifier: "DriverLoginViewController") as? DriverLoginViewController
            
            self.navigationController?.pushViewController(vc!, animated: true)
        }
       
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func googleAction(_ sender: Any) {
        performGoogleSignInAction()
        
        socialHandler = { [weak self](param, secondParam) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.performGoogleSignIn(param: param, secondParam: secondParam)
            })
        }
    }
    
    @IBAction func fBAction(_ sender: Any) {
        
        performFaceBookSignInAction()
        
        socialHandler = { [weak self](param, secondParam) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.performFBSignIn(param: param, secondParam: secondParam)
            })
        }
      
    }
    
    @IBAction func loginAction(_ sender: Any?) {
        
        self.view.endEditing(true)
        
        guard let email = emailTextField.text?.trimWhiteSpace(), let pass = passwordTextField.text?.trimWhiteSpace(), !email.isEmpty, !pass.isEmpty, email.isValidEmail() else {
            //Throw error
            presentAlert(title: nil, message: "Invalid Email or Password")
            return
        }
    
        
        let deviceType = "1" //iOS
        let deviceUdid =  UIDevice.current.identifierForVendor?.uuidString
        let deviceToken = (UIApplication.shared.delegate as? AppDelegate)!.devicePushNotificationToken
        
        showLoadSpinner(message: "Signin ...")
        
        let param = ["email": email, "password": pass, "device_type": deviceType, "device_id": deviceUdid, "device_token": deviceToken]
        let loginAPi = LoginNetworkModel()
        loginAPi.performSignIn(param: param as [String : AnyObject]) { [weak self](success, response, error) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                if success {
                    
                    let message = response?["message"] as? String
                    
                    if response?["status"] as? Int == 200 {
                        
                          if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            if let userToken = innerData["token"] as? String, let userId = innerData["user_id"] as? String {
                                UserDefaults.standard.set(userToken, forKey: "userToken")
                                UserDefaults.standard.set(userId, forKey: "userId")
                                UserDefaults.standard.synchronize()
                                
                                (UIApplication.shared.delegate as? AppDelegate)?.switchToDashboard()
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
    
    @IBAction func forgotAction(_ sender: Any) {
        
        guard  let forgotVC = storyboard?.instantiateViewController(withIdentifier: "ForgotViewController") as? ForgotViewController else {
            return
        }
        
        forgotVC.willMove(toParent: self)
        self.view.addSubview(forgotVC.view)
        self.addChild(forgotVC)
        forgotVC.didMove(toParent: self)
        
    }
}

extension LoginViewController: UITextFieldDelegate {
    
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

extension LoginViewController {
    
    func showPhoneVerification(param : [String: AnyObject], isFBLogin: Bool) {
        
        DispatchQueue.main.async {
            
            guard let phoneVerfication = self.storyboard?.instantiateViewController(withIdentifier: "LoginPhoneVerificationVC") as? LoginPhoneVerificationVC else {
                return
            }
            
            if let email = param["email"] as? String {
                phoneVerfication.email = email
            }
            phoneVerfication.isFBLogin = isFBLogin
            phoneVerfication.param = param
            
            self.navigationController?.pushViewController(phoneVerfication, animated: true)
        }
    }
    
    func performGoogleSignIn(param : [String: AnyObject], secondParam : [String: AnyObject])  {
        
        showLoadSpinner(message: "Google Signin ...")

        iCleanManager.sharedInstance.preformGoogleSignIn(param: param) {[weak self] (success, result, error) in
         
            DispatchQueue.main.async(execute: { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.hideLoadSpinner()
             if success {
                
                let message = result?["message"] as? String
                
                if result?["status"] as? Int == 404 {
                    strongSelf.showPhoneVerification(param: param.mergedWith(otherDictionary: secondParam), isFBLogin: false)
                } else  if result?["status"] as? Int == 200 {
                    
                    if let innerData = result?["data"] as? [String: AnyObject] {
                        
                        if let userToken = innerData["token"] as? String, let userId = innerData["user_id"] as? String {
                            UserDefaults.standard.set("1", forKey: "isFbGL")
                            UserDefaults.standard.set(userToken, forKey: "userToken")
                            UserDefaults.standard.set(userId, forKey: "userId")
                            UserDefaults.standard.synchronize()
                            
                            (UIApplication.shared.delegate as? AppDelegate)?.switchToDashboard()
                        }
                    }
                    
                } else {
                    strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                }
             } else {
                strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
            }
            })
        }
    }
    
    func performFBSignIn(param : [String: AnyObject], secondParam : [String: AnyObject])  {
        
        debugPrint(param,secondParam)
        
        showLoadSpinner(message: "Facebook Signin ...")

        iCleanManager.sharedInstance.preformFBSignIn(param: param) {[weak self] (success, result, error) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                if success {
                    
                    let message = result?["message"] as? String
                    
                    if result?["status"] as? Int == 404 {
                        strongSelf.showPhoneVerification(param: param.mergedWith(otherDictionary: secondParam), isFBLogin: true)
                    } else  if result?["status"] as? Int == 200 {
                        
                        if let innerData = result?["data"] as? [String: AnyObject] {
                            
                            if let userToken = innerData["token"] as? String, let userId = innerData["user_id"] as? String {
                                
                                UserDefaults.standard.set("1", forKey: "isFbGL")
                                UserDefaults.standard.set(userToken, forKey: "userToken")
                                UserDefaults.standard.set(userId, forKey: "userId")
                                UserDefaults.standard.synchronize()
                                
                                (UIApplication.shared.delegate as? AppDelegate)?.switchToDashboard()
                            }
                        }
                        
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                }
            })
        }
    }

}

