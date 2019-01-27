//
//  AddLocationVC.swift
//  iClean
//
//  Created by Anand on 16/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class AddLocationViewController: BaseViewController {

    @IBOutlet weak var tableview: UITableView!
    fileprivate var locationInputlist: [UserObject] = []
    fileprivate var locationStateInputlist: [UserObject] = []
    fileprivate var selectedtag : Int = 0

    @IBOutlet weak var leaveDoorManBtn: ICButton!
    
    var isLoginFlow: Bool = false
    var address: UserAddress?
    
    var addressHandler : ((_ isaddressAdded: Bool )-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !iCleanManager.sharedInstance.isBrainTreeTokenAvailable() {
            iCleanManager.sharedInstance.fetchBrainTreeToken()
        }

        locationInputlist =  getLocationInputs()
        locationStateInputlist = getLocationStateInputs()
        
        addKeyBoardNotification()
        
        keyboardHandler = { isKeyBoardShown in
            if isKeyBoardShown {
                self.tableview.contentInset = UIEdgeInsets(top: -120, left: 0, bottom: 0, right: 0)
            } else {
                self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
        
        if address != nil  && isLoginFlow == false {
            updateAddressList()
             leaveDoorManBtn.isSelected = address?.leaveAtDoorman ?? false
        }
    }
    
    fileprivate func updateAddressList() {
        
        for loc in locationInputlist {
            if let key = loc.keyName {
                loc.name = address?.value(forKey: key) as? String
            }
        }
        
        for loc in locationStateInputlist {
            if let key = loc.keyName {
                loc.name = address?.value(forKey: key) as? String
            }
        }
        
        self.tableview.reloadData()
    }

    func getKeyboardAccessoryView(_ textField: UITextField,  title : String) {
        
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
            resetTableViewScroll()
        }
        else {
            
            if tag >= 4 {
                
                if let cell = tableview.cellForRow(at: IndexPath(row: 0, section: 1)) as? LocationStateCell {
                    
                    if tag == 4 {
                        cell.stateField.becomeFirstResponder()
                    } else {
                        cell.zipField.becomeFirstResponder()

                    }
                }
            } else {
                if let cell = tableview.cellForRow(at: IndexPath(row: tag + 1, section: 0)) as? LocationInfoCell {
                    cell.userTextField.becomeFirstResponder()
                }
            }
            
        }
    }
    
    fileprivate func resetTableViewScroll() {
        
        self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.endEditing(true)
    }
    
    
    @IBAction func skipAction(_ sender: Any) {
        
        showCreditCard()
    }
    
    @IBAction func AddButtonAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        var param : [String: AnyObject] = [:]

        for user in locationInputlist {
            
            guard let name = user.name?.trimWhiteSpace(), !name.isEmpty, (user.keyName != "apartment_name" || user.keyName != "gate_code") else {
                presentAlert(title: nil, message: user.errorMessage!)
                return
            }
            
            param[user.keyName!] = name.encodeEmoji as AnyObject
        }
        
        for user in locationStateInputlist {
            
            guard let name = user.name?.trimWhiteSpace(), !name.isEmpty else {
                presentAlert(title: nil, message: user.errorMessage!)
                return
            }
            
            param[user.keyName!] = name.encodeEmoji as AnyObject

        }
        
        param["leave_with_doorman"] = self.leaveDoorManBtn.isSelected as AnyObject
        
        if address == nil || isLoginFlow == true {
            addLocation(param: param)
        } else {
            updateAddress(param: param)
        }

    }
    
    @IBAction func leaveAtDoorManAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    fileprivate func showCreditCard() {
        
            DispatchQueue.main.async {
                
                guard let addLocation = self.storyboard?.instantiateViewController(withIdentifier: GeneralConstants.registerAddCardVC) as? AddCardViewController else {
                    return
                }
                addLocation.isLoginFlow = self.isLoginFlow
                self.navigationController?.pushViewController(addLocation, animated: true)
            }
    }
}

extension AddLocationViewController {
    
    fileprivate func updateAddress(param : [String: AnyObject]) {
        showLoadSpinner(message: "Updating Address ...")
        
        LocationNetworkModel().updateAddress(param: param, for: address?.uid ?? "1") { (success, response, error) in
            
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
                        
                        strongSelf.showCustomPopView(popupType: .Success, title: "Great news!\nWe service your area!", customBtnTitle: nil, handler: { [weak self](isDone) in
                            
                            guard let strongSelf = self else {
                                return
                            }
                            
                            strongSelf.navigationController?.popViewController(animated: true)

                            if let handler = strongSelf.addressHandler {
                                    handler(true)
                            }
                        })
                        
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                    }
                    
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                }
            })
        }

    }
    
    fileprivate func addLocation(param : [String: AnyObject]) {
        
        showLoadSpinner(message: "Storing Address ...")
        
        LocationNetworkModel().addAddress(param: param) { (success, response, error) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                if success {
                    let message = response?["message"] as? String
                    //  strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                    
                    if response?["status"] as? Int == 201 {
                        
                        strongSelf.showCustomPopView(popupType: .Success, title: "Great news!\nWe service your area!", customBtnTitle: nil, handler: { [weak self](isDone) in
                            
                            guard let strongSelf = self else {
                                return
                            }
                            
                            if strongSelf.isLoginFlow == true {
                                strongSelf.showCreditCard()
                            } else {
                              
                                strongSelf.navigationController?.popViewController(animated: true)
                                
                                if let handler = strongSelf.addressHandler {
                                    handler(true)
                                }
                            }
                        })
                        
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

extension AddLocationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 5 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.locationInfoCell) as? LocationInfoCell
            
            let user = locationInputlist[indexPath.row]
            cell?.userTextField.placeholder = user.placeholder
            cell?.userTextField.text = user.name
            cell?.userTextField.keyboardType = user.keyboardType
            cell?.userTextField.returnKeyType = user.returnType
            cell?.userTextField.tag = indexPath.row
            cell?.userTextField.delegate = self
            
            if cell?.userTextField.inputAccessoryView == nil {
                self.getKeyboardAccessoryView(cell?.userTextField ?? UITextField(), title: "Next")
            }
            
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.locationStateCell) as? LocationStateCell
            
            let state = locationStateInputlist[0]
            let zip = locationStateInputlist[1]

            cell?.stateField.placeholder = state.placeholder
            cell?.stateField.text = state.name
            cell?.stateField.keyboardType = state.keyboardType
            cell?.stateField.returnKeyType = state.returnType
            cell?.stateField.delegate = self
            cell?.stateField.tag = 100
            
            cell?.zipField.placeholder = zip.placeholder
            cell?.zipField.text = zip.name
            cell?.zipField.keyboardType = zip.keyboardType
            cell?.zipField.returnKeyType = zip.returnType
            cell?.zipField.delegate = self
            cell?.zipField.tag = 101
            
           
            if cell?.stateField.inputAccessoryView == nil {
                self.getKeyboardAccessoryView(cell?.stateField ?? UITextField(), title: "Next")
            }
            
            
            if cell?.zipField.inputAccessoryView == nil {
                self.getKeyboardAccessoryView(cell?.zipField ?? UITextField(), title: "Done")
            }
            
            return cell!
        }
    }
    
}

extension AddLocationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        selectedtag = textField.tag
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag < 100{
            locationInputlist[textField.tag].name =  textField.text
        } else {
            locationStateInputlist[textField.tag - 100].name = textField.text
        }
    
    }
    
}

extension AddLocationViewController {
    
    fileprivate func getLocationInputs() -> [UserObject] {
        
        let userName = UserObject()
        userName.placeholder = "Nickname for Location"
        userName.keyboardType = .asciiCapable
        userName.keyName = "nickname"
        userName.errorMessage = "Please enter location nickname"
        
        let address = UserObject()
        address.placeholder = "Address 1"
        address.keyboardType = .asciiCapable
        address.keyName = "address_1"
        address.errorMessage = "Please add your address"
        
        let apartment = UserObject()
        apartment.placeholder = "Apartment Number"
        apartment.keyboardType = .asciiCapable
        apartment.keyName = "apartment_name"
        apartment.errorMessage = "Please add apartment name"
        apartment.name = ""
        
        let gatecode = UserObject()
        gatecode.placeholder = "Gate Code"
        gatecode.keyboardType = .asciiCapable
        gatecode.keyName = "gate_code"
        gatecode.errorMessage = "Please add your gate code"
        gatecode.name = ""

        
        let city = UserObject()
        city.placeholder = "City"
        city.keyboardType = .asciiCapable
        city.keyName = "city"
        city.errorMessage = "Please add city name"
        
        return [userName, address, apartment, gatecode, city]
    }
    
    fileprivate func getLocationStateInputs() -> [UserObject] {
        
        let state = UserObject()
        state.placeholder = "State"
        state.keyboardType = .asciiCapable
        state.keyName = "state"
        state.errorMessage = "Please add state name"
        
        let zip = UserObject()
        zip.placeholder = "Zip"
        zip.keyboardType = .asciiCapable
        zip.keyName = "zip_code"
        zip.errorMessage = "Please add zip code"
        
        return [state, zip]
    }
    
}
