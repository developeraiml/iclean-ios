//
//  RegisterViewController.swift
//  iClean
//
//  Created by Anand on 28/09/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class RegisterViewController: LoginBaseViewController {

    fileprivate var userInfo: [UserInput]?
    @IBOutlet weak var checkBtnStatus: UIButton!
    
    @IBOutlet weak var tableview: UITableView!
    
    fileprivate var selectedtag : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userInfo = self.setUserInputs()
        addKeyBoardNotification()
        
        keyboardHandler = { isKeyBoardShown in
            if isKeyBoardShown {
                self.tableview.contentInset = UIEdgeInsets(top: -120, left: 0, bottom: 0, right: 0)
            } else {
                self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func checkButtonAction(_ sender: Any) {
    
        self.checkBtnStatus.isSelected = !self.checkBtnStatus.isSelected
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        guard let nameObj = userInfo?[0], let name = nameObj.name?.trimWhiteSpace(), !name.isEmpty else {
            presentAlert(title: nil, message: "Please enter Your Name.")
            return
        }
        
        guard let emailObj = userInfo?[1], let email = emailObj.name?.trimWhiteSpace(), !email.isEmpty, email.isValidEmail() == true else {
            presentAlert(title: nil, message: "Please add valid Email.")
            return
        }
        
        guard let passObj = userInfo?[2], let pass = passObj.name?.trimWhiteSpace(), !pass.isEmpty else {
            presentAlert(title: nil, message: "Please add your Password.")
            return
        }
        
        guard let phoneObj = userInfo?[3], let phone = phoneObj.name?.trimWhiteSpace(), !phone.isEmpty else {
            presentAlert(title: nil, message: "Please add valid phone number.")
            return
        }
        
        guard let zipObj = userInfo?[4], let zip = zipObj.name?.trimWhiteSpace(), !zip.isEmpty else {
            presentAlert(title: nil, message: "Please add valid Zipcode.")
            return
        }
        
        guard self.checkBtnStatus.isSelected == true else {
            presentAlert(title: nil, message: "Please accept Terms & Conditions.")
            return
        }
        
        
        let deviceType = "1" //iOS
        let deviceUdid =  UIDevice.current.identifierForVendor?.uuidString
        let deviceToken = (UIApplication.shared.delegate as? AppDelegate)!.devicePushNotificationToken
        
        showLoadSpinner(message: "Signin Up ...")
        
        let param = ["name": name, "email": email, "password": pass, "phone_number": phone, "zip_code": zip, "device_type": deviceType, "device_id": deviceUdid, "device_token": deviceToken]
        
        let regApi = LoginNetworkModel()
        regApi.performSignup(param: param as [String: AnyObject]) { (success, response, error) in
          //  debugPrint(response)
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                
                if success {
                    
                   // let message = response?["message"] as? String
                    if response?["status"] as? Int == 201 {
                        
                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            if let userToken = innerData["token"] as? String, let userId = innerData["user_id"] as? String {
                                UserDefaults.standard.set(userToken, forKey: "userToken")
                                UserDefaults.standard.set(userId, forKey: "userId")
                                UserDefaults.standard.synchronize()
                                
                                strongSelf.showPopView(popupType: .Success, handler: { [weak self](isDone) in
                                    
                                    guard let strongSelf = self else {
                                        return
                                    }
                                    strongSelf.showAddLocation()
                                   // (UIApplication.shared.delegate as? AppDelegate)?.switchToDashboard()
                                })
                            }
                            
                        }
                        
                    } else if response?["status"] as? Int == 475 {
                        
                        strongSelf.showPopView(popupType: .Sorry, handler: nil)
                       
                    } else {
                        
                        if let innerData = response?["data"] as? [String: AnyObject] {
                            if let errors = innerData["errors"] as? [String] {
                                  strongSelf.presentAlert(title: nil, message: errors.joined(separator: ", "))
                            }
                        }
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                }
            })
        }
       
    }
    
    @IBAction func TermsConditionStatusAction(_ sender: Any) {
    }
    
    
    @IBAction func facebookAction(_ sender: Any) {
        performFaceBookSignInAction()
        
        socialHandler = { [weak self](param, secondParam) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.performFBSignIn(param: param, secondParam: secondParam)
            })
        }
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
    
    func getKeyboardAccessoryView(_ textField: UITextField, title : String) {
        
        let bar = UIToolbar()
        bar.tag = textField.tag
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(doneAction))
        bar.items = [flexBarButton,done]
        bar.sizeToFit()
        textField.inputAccessoryView = bar
        
    }
    
    @objc func doneAction(sender: UIBarButtonItem) {
        
        let tag = selectedtag
        if sender.title == "Done" {
            self.view.endEditing(true)
        } else {
            
            if let cell = tableview.cellForRow(at: IndexPath(row: tag + 1, section: 0)) as? RegisterCell {
                cell.userTextField.becomeFirstResponder()
            }
            
        }
        
    }
}

extension RegisterViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfo?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCell") as? RegisterCell
        
        let user = self.userInfo?[indexPath.row]
        
        cell?.userTextField.placeholder = user?.placeholder
        cell?.userTextField.text = user?.name
        cell?.userTextField.keyboardType = user?.keyboardType ?? .asciiCapable
        cell?.userTextField.returnKeyType = user?.returnType ?? .done
        cell?.userTextField.isSecureTextEntry = user?.isSecured ?? false
        cell?.userTextField.delegate = self
        cell?.userTextField.autocorrectionType = .no
        cell?.userTextField.tag = indexPath.row
        
        let inputAccessoryTitle = user?.returnType == .done ? "Done" : "Next"
        
        if cell?.userTextField.inputAccessoryView == nil {
            self.getKeyboardAccessoryView(cell?.userTextField ?? UITextField(), title: inputAccessoryTitle)
        }
        
        
        return cell!
    }

}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        selectedtag = textField.tag
        if let textfield = textField as? RaisePlaceholder {
            textfield.textFieldDidEditinfBegin()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        userInfo?[textField.tag].name =  textField.text
        
        if let textfield = textField as? RaisePlaceholder {
            textfield.textFieldDidEditingEnded()
        }
    }
    
    
    fileprivate func setUserInputs() -> [UserInput] {
        
        let userName = UserInput(name: "", placeholder: "Name", keyboardType: UIKeyboardType.asciiCapable, returnType: UIReturnKeyType.next, isSecured: false)
        
        let email = UserInput(name: "", placeholder: "Email", keyboardType: UIKeyboardType.emailAddress, returnType: UIReturnKeyType.next, isSecured: false)

        let password = UserInput(name: "", placeholder: "Password", keyboardType: UIKeyboardType.asciiCapable, returnType: UIReturnKeyType.next, isSecured: true)
        
         let phone = UserInput(name: "", placeholder: "Phone Number", keyboardType: UIKeyboardType.numberPad, returnType: UIReturnKeyType.next, isSecured: false)
        
        let zipcode = UserInput(name: "", placeholder: "Zip Code", keyboardType: UIKeyboardType.asciiCapable, returnType: UIReturnKeyType.done, isSecured: false)

        
        return [userName, email, password, phone, zipcode]
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return true
        }
        let lastText = (text as NSString).replacingCharacters(in: range, with: string) as String
        
         let user = userInfo?[textField.tag]
        
        if user?.placeholder == "Phone Number" {
            textField.text = lastText.format("NNN-NNN-NNNN", oldString: text)
            return false
        }
        
         return true
    }
    
    func showAddLocation() {
        
        DispatchQueue.main.async {
            
            guard let addLocation = self.storyboard?.instantiateViewController(withIdentifier: "RegAddLocationVC") as? AddLocationVC else {
                return
            }
            addLocation.isLoginFlow = true
            self.navigationController?.pushViewController(addLocation, animated: true)
        }
    }
}


extension RegisterViewController {
    
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
    
    func performFBSignIn(param : [String: AnyObject], secondParam : [String: AnyObject])  {
        
        showLoadSpinner(message: "Facebook Signup ...")
        
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
    
    func performGoogleSignIn(param : [String: AnyObject], secondParam : [String: AnyObject])  {
        
        showLoadSpinner(message: "Google Signup ...")

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
    
}

