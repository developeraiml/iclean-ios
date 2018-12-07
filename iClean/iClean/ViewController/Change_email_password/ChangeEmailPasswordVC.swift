//
//  ChangeEmailPasswordVC.swift
//  iClean
//
//  Created by Anand on 02/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class ChangeEmailPasswordVC: BaseViewController,UITextFieldDelegate {

    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var tableview: UITableView!
    fileprivate var cardInputlist: [UserObject]? = []
    
    var isChangeEmailScreen : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if isChangeEmailScreen {
            cardInputlist = getEmailInputs()
        }
        else{
            cardInputlist = getPasswordInputs()
            self.navTitle.text = "Change Password"
        }
        
        tableview.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tableview.backgroundView = UIView()
        self.tableview.backgroundView?.addGestureRecognizer(tap)

    }
    

    fileprivate func getEmailInputs() -> [UserObject] {
        
        let userName = UserObject()
        userName.placeholder = "Current E-mail"
        userName.keyboardType = .emailAddress
        userName.keyName = "email"
        userName.errorMessage = "Please add valid email"
        
        let cardNo = UserObject()
        cardNo.placeholder = "New E-mail"
        cardNo.keyboardType = .emailAddress
        cardNo.keyName = "new_email_1"
        cardNo.errorMessage = "Please add valid email"
        
        let cardName = UserObject()
        cardName.placeholder = "Retype New E-mail"
        cardName.keyboardType = .emailAddress
        cardName.keyName = "new_email_2"
        cardName.errorMessage = "email does not match with new email"
        
        
        return [userName, cardNo, cardName]
    }
    
    fileprivate func getPasswordInputs() -> [UserObject] {
        
        let userName = UserObject()
        userName.placeholder = "Current Password"
        userName.keyboardType = .asciiCapable
        userName.keyName = "password"
        userName.errorMessage = "Please enter current password"
        
        let cardNo = UserObject()
        cardNo.placeholder = "New Password"
        cardNo.keyboardType = .asciiCapable
        cardNo.keyName = "new_password_1"
        cardNo.errorMessage = "Please add new password"
        
        let cardName = UserObject()
        cardName.placeholder = "Retype New Password"
        cardName.keyboardType = .asciiCapable
        cardName.keyName = "new_password_2"
        cardName.errorMessage = "retyped password does not match with new password"
        
        
        return [userName, cardNo, cardName]
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if isChangeEmailScreen {
            changeEmail()
        }
        else{
            changePassword()
        }

    }
    
    fileprivate func changeEmail() {
        
        guard let obj = cardInputlist?[0], let email = obj.keyName?.trimWhiteSpace(), !email.isEmpty, email.isValidEmail() == true else {
            presentAlert(title: nil, message: "Please add valid Email.")
            return
        }
        
        guard let emailObj = cardInputlist?[1], let email1 = emailObj.name?.trimWhiteSpace(), !email1.isEmpty, email1.isValidEmail() == true else {
            presentAlert(title: nil, message: "Please add valid Email.")
            return
        }
        
        guard let emailObj1 = cardInputlist?[2], let email2 = emailObj1.name?.trimWhiteSpace(), !email2.isEmpty, email2.isValidEmail() == true else {
            presentAlert(title: nil, message: "Please add valid Email.")
            return
        }
        
        let api = OthersNetworkModel()
        
        guard let key1 = obj.keyName else{
            return
        }
        guard let key2 = emailObj.keyName else {
            return
        }
        guard let key3 = emailObj1.keyName else {
            return
        }
        
        let dict = [key1: email,
                    key2: email1,
                    key3: email2]
        
        showLoadSpinner(message: "Updating Email ...")
        
        api.updateEmail(param: dict as [String : AnyObject]) { (success, response, error) in
            
            debugPrint(response)
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                if success {
                    let message = response?["message"] as? String
                    //  strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                    
                    if response?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                appDel.switchToLogin()
                            }
                        })
                        
                    } else if response?["status"] as? Int == 200 {
                        //strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                        
                        strongSelf.showCustomPopView(popupType: .Success, title: message ?? "Api error", customBtnTitle: "OKAY", handler: { (status) in
                            //Logout
                            (UIApplication.shared.delegate as! AppDelegate).switchToLogin()
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
    
    fileprivate func changePassword() {
        
        guard let obj = cardInputlist?[0], let pass = obj.name?.trimWhiteSpace(), !pass.isEmpty, obj.isValid else {
            presentAlert(title: nil, message: "Password should be min of 4 digits.")
            return
        }
        
        guard let Obj1 = cardInputlist?[1], let pass1 = Obj1.name?.trimWhiteSpace(), !pass1.isEmpty, Obj1.isValid else {
            presentAlert(title: nil, message: "Password should be min of 4 digits.")
            return
        }
        
        guard let Obj2 = cardInputlist?[2], let pass2 = Obj2.name?.trimWhiteSpace(), !pass2.isEmpty, Obj2.isValid else {
            presentAlert(title: nil, message: "Password should be min of 4 digits.")
            return
        }
        
        guard pass1 == pass2 else {
            presentAlert(title: nil, message: "Password mismatch")
            return
        }
        
        let api = OthersNetworkModel()
        guard let key1 = obj.keyName else{
            return
        }
        guard let key2 = Obj1.keyName else {
            return
        }
        guard let key3 = Obj2.keyName else {
            return
        }

        let dict = [key1: pass,
                    key2: pass1,
                    key3: pass2]
        
        showLoadSpinner(message: "Updating Password ...")
        
        api.updatePassword(param: dict as [String : AnyObject]) { (success, response, error) in
            debugPrint(response!)
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                if success {
                    let message = response?["message"] as? String
                    //  strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                    
                    if response?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                appDel.switchToLogin()
                            }
                        })
                        
                    } else if response?["status"] as? Int == 200 {
                        //strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                        
                        strongSelf.showCustomPopView(popupType: .Success, title: message ?? "Api error", customBtnTitle: "OKAY", handler: { (status) in
                            //Logout
                            (UIApplication.shared.delegate as! AppDelegate).switchToLogin()
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
    
}


extension ChangeEmailPasswordVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? cardInputlist?.count ?? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeEmailPasswordCell") as? ChangeEmailPasswordCell
            
            let user = cardInputlist?[indexPath.row]
            cell?.userTextField.placeholder = user?.placeholder
            cell?.userTextField.text = user?.name
            cell?.userTextField.keyboardType = user?.keyboardType ?? .asciiCapable
            cell?.userTextField.returnKeyType = user?.returnType ?? .default
            cell?.userTextField.tag = indexPath.row
            cell?.userTextField.delegate = self
        
            cell?.userTextField.isSecureTextEntry = false

            if isChangeEmailScreen == false && indexPath.row == 0{
                cell?.userTextField.isSecureTextEntry = true
            }
        
            cell?.statusIcon.isHighlighted = user?.isValid ?? false
        
            return cell!
            
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        cardInputlist?[textField.tag].name =  textField.text
        cardInputlist?[textField.tag].isValid = false

        if isChangeEmailScreen {
            if textField.text?.isEmail == true {
                cardInputlist?[textField.tag].isValid = true
            }
            
        } else {

            if textField.text?.isEmpty == false, textField.text?.count ?? 0 > 4 {
                cardInputlist?[textField.tag].isValid = true
            }
        }
        
        tableview.reloadRows(at: [IndexPath(row: textField.tag, section: 0)], with: .automatic)
        
    }
    
}
