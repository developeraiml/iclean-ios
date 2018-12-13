//
//  AddCardVC.swift
//  iClean
//
//  Created by Anand on 17/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree

class AddCardViewController: BaseViewController {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    fileprivate var cardInputlist: [UserObject] = []
    fileprivate var cardCvvInputlist: [UserObject] = []

    var cardInfo : Card?
    
    var isLoginFlow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        cardInputlist =  getCardInputs()
        cardCvvInputlist = getCardCvvInputs()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tableview.backgroundView = UIView()
        self.tableview.backgroundView?.addGestureRecognizer(tap)
        
        //showAddCardUI()
        
        if cardInfo != nil {
            
            self.addBtn.setTitle("Update", for: .normal)
            
            cardCvvInputlist[0].name = cardInfo?.expiry
            cardCvvInputlist[0].isEditable = false
            
            cardCvvInputlist[1].name = "***"
            cardCvvInputlist[1].isEditable = false
            
            cardInputlist[0].name = cardInfo?.nickName

            if cardInfo?.nickName?.lowercased() == "choose nickname" {
                cardInputlist[0].name = ""
            }
            
            
            cardInputlist[1].name = "XXXX-XXXX-XXXX-" + (cardInfo?.cardNumber ?? "")
            cardInputlist[1].isEditable = false

             cardInputlist[2].name = cardInfo?.name
            cardInputlist[2].isEditable = false

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isLoginFlow {
            showAddCardUI()
        }
    }

    @objc func tableTapped(tap:UITapGestureRecognizer) {
        self.view.endEditing(true)
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
        self.view.endEditing(true)
        
    }

    @IBAction func addCardAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if cardInfo != nil {
            
            let api = BraintreeNetworkModel()
            
            let dict = ["card_id" : cardInfo?.cardId ?? 0,
                        "nickname": cardInputlist[0].name ?? ""] as [String : AnyObject]
            
            showLoadSpinner(message: "Updating Card ...")
            
            api.updateCard(dict) { (success, response, error) in
                
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
                            
                            strongSelf.presentAlert(title: nil, message: message ?? "Card updated Successfully", completion: { (status) in
                                strongSelf.navigationController?.popViewController(animated: true)
                            })
                        } else{
                            strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                        }
                        
                    } else {
                        strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                    }
                })
            }
        }
        
        
    }
}

extension AddCardViewController {
    
    func showWashSetting() {
        
        DispatchQueue.main.async {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: GeneralConstants.registerWashSettingVC) as? WashSettingsViewController
            
            self.navigationController?.pushViewController(VC!, animated: true)
        }
        
    }
    
    func showAddCardUI() {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: iCleanManager.sharedInstance.brainTreeClientToken, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
                self.showWashSetting()
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                
//                debugPrint(result.paymentOptionType)
//                debugPrint(result.paymentMethod) // payment menthod is Nonce
//                debugPrint(result.paymentDescription)
//                debugPrint(result.paymentIcon)
//                debugPrint(result.paymentMethod?.nonce) // payment menthod is Nonce
                
                if let nonce = result.paymentMethod?.nonce {
                    self.addCard(nonce: nonce)
                }
                
                
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        if let drop = dropIn {
            self.present(drop, animated: true, completion: nil)
        }
    }
    
    fileprivate func addCard(nonce : String) {
        
        let api = BraintreeNetworkModel()
        api.addCard(nonce) { [weak self] (success, response, error) in
            
            self?.showWashSetting()
        }
    }
    
}

extension AddCardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? cardInputlist.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.locationInfoCell) as? LocationInfoCell
            
            let user = cardInputlist[indexPath.row]
            cell?.userTextField.placeholder = user.placeholder
            cell?.userTextField.text = user.name
            cell?.userTextField.keyboardType = user.keyboardType
            cell?.userTextField.returnKeyType = user.returnType
            cell?.userTextField.tag = indexPath.row
            cell?.userTextField.delegate = self
            
            cell?.userTextField.isEnabled = user.isEditable
            
            if cell?.userTextField.inputAccessoryView == nil {
                self.getKeyboardAccessoryView(cell?.userTextField ?? UITextField())
            }
            
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.locationStateCell) as? LocationStateCell
            
            let state = cardCvvInputlist[0]
            let zip = cardCvvInputlist[1]
            
            cell?.stateField.placeholder = state.placeholder
            cell?.stateField.text = state.name
            cell?.stateField.keyboardType = state.keyboardType
            cell?.stateField.returnKeyType = state.returnType
            cell?.stateField.delegate = self
            cell?.stateField.isEnabled = state.isEditable

            
            cell?.zipField.placeholder = zip.placeholder
            cell?.zipField.text = zip.name
            cell?.zipField.keyboardType = zip.keyboardType
            cell?.zipField.returnKeyType = zip.returnType
            cell?.zipField.delegate = self
            cell?.zipField.isEnabled = zip.isEditable

            cell?.stateField.tag = indexPath.section * 10
            cell?.zipField.tag  = (indexPath.section + 1) * 10
            
            if cell?.zipField.inputAccessoryView == nil {
                self.getKeyboardAccessoryView(cell?.zipField ?? UITextField())
            }
            
            return cell!
        }
    }
    
}

extension AddCardViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        if textField.tag < 10 {
            let cardInfo = cardInputlist[textField.tag]
            cardInfo.name = textField.text

        } else {
            
            let cardInfo = cardCvvInputlist[textField.tag - 10]
            cardInfo.name = textField.text
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return true
        }
        
        if textField.tag < 10 {
            let cardInfo = cardInputlist[textField.tag]
            
            if cardInfo.placeholder == "Credit card Number" {
                let lastText = (text as NSString).replacingCharacters(in: range, with: string) as String
                textField.text = lastText.format("NNNN NNNN NNNN NNNN", oldString: text)
                return false
            }
        } else {
            
            if textField.tag == 10 {
                let lastText = (text as NSString).replacingCharacters(in: range, with: string) as String
                textField.text = lastText.format("NN/NN", oldString: text)
                return false
            } else {
                let lastText = (text as NSString).replacingCharacters(in: range, with: string) as String
                textField.text = lastText.format("NNN", oldString: text)
                return false
            }

        }
       
        
         return true
    }
    
}

extension AddCardViewController {
    
    fileprivate func getCardInputs() -> [UserObject] {
        
        let userName = UserObject()
        userName.placeholder = "Nickname"
        userName.keyboardType = .asciiCapable
        userName.keyName = "nickname"
        userName.errorMessage = "Please enter your nickname"
        userName.returnType = .done
        
        let cardNo = UserObject()
        cardNo.placeholder = "Credit card Number"
        cardNo.keyboardType = .numberPad
        cardNo.keyName = "nickname"
        cardNo.errorMessage = "Please add card Number"
        
        let cardName = UserObject()
        cardName.placeholder = "Name on Card"
        cardName.keyboardType = .asciiCapable
        cardName.keyName = "nickname"
        cardName.errorMessage = "Please add name shown on card"
       
        
        return [userName, cardNo, cardName]
    }
    
    fileprivate func getCardCvvInputs() -> [UserObject] {
        
        let month = UserObject()
        month.placeholder = "MM/YY"
        month.keyboardType = .numberPad
        month.keyName = "nickname"
        month.errorMessage = "Please enter valid month and year"
        
        let cvv = UserObject()
        cvv.placeholder = "CVV"
        cvv.keyboardType = .numberPad
        cvv.keyName = "nickname"
        cvv.errorMessage = "Please enter your cvv code"
        
        return [month, cvv]
    }
    
}
