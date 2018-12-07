//
//  LoginPhoneVerificationVC.swift
//  iClean
//
//  Created by Anand on 16/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class LoginPhoneVerificationVC: BaseViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var captipnTitle: UILabel!
    var email: String?
    var phone: String?
    var zipcode: String?
    
    var isFBLogin: Bool = true
    var param: [String: AnyObject]?
    
    fileprivate var userList: [UserObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if isFBLogin == false {
            captipnTitle.text = "You are logged in with Google!"
        }
        
        userList.append(getEmail())
        userList.append(getPhoneNumber())
        userList.append(getZipCode())
        if email != nil {
            userList[0].name = email
        }
        
        if phone != nil {
            userList[1].name = phone

        }
        
        if zipcode != nil {
            userList[2].name = zipcode
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tableview.backgroundView = UIView()
        self.tableview.backgroundView?.addGestureRecognizer(tap)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetTableViewScroll()
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer) {
        resetTableViewScroll()

    }
    
    func getPhoneNumber() -> UserObject {
        
        let obj = UserObject()
        obj.captionPlaceholder = "Enter your phone number"
        obj.placeholder = "323-xxx-xxxx"
        obj.textFormat = "NNN-NNN-NNNN"
        obj.keyboardType = .numberPad
        obj.keyName = "phone_number"
        obj.errorMessage = "Please enter your phone"
        obj.tag = 1
        return obj
    }
    
    func getEmail() -> UserObject {
        
        let obj = UserObject()
        obj.captionPlaceholder = "Enter your email"
        obj.placeholder = "email"
       // obj.textFormat = "NNN-NNN-NNNN"
        obj.keyboardType = .emailAddress
        obj.returnType = .next
        obj.keyName = "email"
        obj.errorMessage = "Please add valid email"

        obj.tag = 2
        return obj
    }
    
    func getZipCode() -> UserObject {
        
        let obj = UserObject()
        obj.captionPlaceholder = "Enter your zipcode"
        obj.placeholder = "zip"
        // obj.textFormat = "NNN-NNN-NNNN"
        obj.keyboardType = .asciiCapable
        obj.returnType = .done
        obj.keyName = "zip_code"
        obj.errorMessage = "Please enter zip code"

        obj.tag = 3
        return obj
    }
    
    
    func getKeyboardAccessoryView(_ textField: UITextField) {
        
        let bar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        bar.items = [flexBarButton,done]
        bar.sizeToFit()
        textField.inputAccessoryView = bar

    }
    
    @objc func doneAction() {
       resetTableViewScroll()
    }
    
    fileprivate func resetTableViewScroll() {
        
        self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.endEditing(true)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        for user in userList {
            
            if user.placeholder == "email" {
                
                guard let email = user.name?.trimWhiteSpace(),!email.isEmpty, email.isValidEmail() else {
                    //Throw error
                    presentAlert(title: nil, message: user.errorMessage ?? "Please add valid email")
                    return
                }
                
                param?[user.keyName ?? "email"] = email as AnyObject
            }
            
            guard let name = user.name?.trimWhiteSpace(),!name.isEmpty else {
                presentAlert(title: nil, message: user.errorMessage ?? "Please add valid input")
                return
            }
            
            param?[user.keyName!] = name as AnyObject
            
        }
        
        if isFBLogin == false {
            self.googleSignUp()
        } else {
            self.facebookSingup()
        }
        
    }

}

extension LoginPhoneVerificationVC {
    
    func showAddLocation() {
        
        DispatchQueue.main.async {
            
            guard let addLocation = self.storyboard?.instantiateViewController(withIdentifier: "RegAddLocationVC") as? AddLocationVC else {
                return
            }
            
            addLocation.isLoginFlow = true
            
            self.navigationController?.pushViewController(addLocation, animated: true)
        }
    }
   
    func facebookSingup() {
        
        guard let params = param else {
            return
        }
        
        showLoadSpinner(message: "Signin Up ...")
        
        iCleanManager.sharedInstance.preformFBSignup(param: params) { (success, response, error) in
           // debugPrint(response)
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                
                if success {
                    
                   // let message = response?["message"] as? String
                    if response?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            strongSelf.navigationController?.popToRootViewController(animated: true)
                        })
                        
                    } else if response?["status"] as? Int == 201 {
                        
                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            if let userToken = innerData["token"] as? String, let userId = innerData["user_id"] as? String {
                                
                                UserDefaults.standard.set("1", forKey: "isFbGL")
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
                            
                           // strongSelf.showPopView(popupType: .Sorry, handler: nil)
                            
                        }
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                }
            })
        }
    }
    
    func googleSignUp()  {
        
        guard let params = param else {
            return
        }
        
        showLoadSpinner(message: "Signin Up ...")
        
        iCleanManager.sharedInstance.preformGoogleSignup(param: params) { (success, response, error) in
            //debugPrint(response)
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                
                if success {
                    
                    // let message = response?["message"] as? String
                    
                    if response?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            strongSelf.navigationController?.popToRootViewController(animated: true)
                        })
                        
                    } else if response?["status"] as? Int == 201 {
                        
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
                            
                          //  strongSelf.showPopView(popupType: .Sorry, handler: nil)
                            
                        }
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                }
            })
        }
    }
}

extension LoginPhoneVerificationVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        userList[textField.tag].name =  textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let height = tableview.frame.height
            
        self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height - 100, right: 0)
        
        let index = IndexPath(row: 0, section: textField.tag)
        
        self.tableview.scrollToRow(at: index, at: .top, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return true
        }
        
        let lastText = (text as NSString).replacingCharacters(in: range, with: string) as String
        
        let user = userList[textField.tag]
        
        if user.textFormat != nil {
            textField.text = lastText.format(user.textFormat ?? "", oldString: text)
            return false
        }
        
        return true
    }
    
}

extension LoginPhoneVerificationVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "phoneVerificationCell") as? phoneVerificationCell
        
        let user = userList[indexPath.section]
        
        cell?.captionTitle.text = user.captionPlaceholder ?? ""
        cell?.verfiyTextField.placeholder = user.placeholder
        cell?.verfiyTextField.text = user.name
        cell?.verfiyTextField.returnKeyType = user.returnType
        cell?.verfiyTextField.keyboardType = user.keyboardType
        cell?.verfiyTextField.tag = indexPath.section
        cell?.verfiyTextField.delegate = self
        
        if (userList.count == indexPath.section + 1) && cell?.verfiyTextField.inputAccessoryView == nil {
            self.getKeyboardAccessoryView(cell?.verfiyTextField ?? UITextField())
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return userList.count
    }
}
