//
//  CustomSettingsVC.swift
//  iClean
//
//  Created by Anand on 18/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class CustomSettingsViewController: BaseViewController {
    
    enum TableSection : Int {
        case Wash
        case DryOption
        case Detergent
        case Instruction
    }

    fileprivate var selectedList = ["",""]
    
    var specialInstruction = ""
    var selectedKeys : [String]?
    
    var isloginFlow : Bool = false
    var useFabricSoftner : Bool = false
    
   

    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addKeyBoardNotification()
        
        keyboardHandler = { isKeyBoardShown in
            if isKeyBoardShown {
                self.tableview.contentInset = UIEdgeInsets(top: -200, left: 0, bottom: 0, right: 0)
            } else {
                self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
        
        if selectedKeys?.contains("fabric_softner") == true {
            useFabricSoftner = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "WashSettingListVC"
        {
            // Store the transaction whose details we wish to view
            if let viewController = segue.destination as? WashSettingListViewController {
                viewController.selectedKeys = selectedKeys
            }
        }
        
    }
    
    fileprivate func getDictParams() -> [String: Any] {
        
        let dict = ["is_iclean_recommended": false, "fabric_softner" : useFabricSoftner, "detergent" : false,
                    "wash_cold" : false, "wash_warm" :false , "wash_hot" : false , "dry_low" : false,
                    "dry_medium" : false, "dry_high" : false, "dry_hang_dry" : false]
        
        return dict
    }

    @IBAction func nextAction(_ sender: Any) {
        
        let list = selectedList.filter({$0 == ""})
        if list.count == 0 {
            
            var dict = getDictParams()
            //var dict: [String: Any] = ["is_iclean_recommended": false]
            dict["is_iclean_recommended"] = false
            
            for sKey in selectedList {
                dict[sKey] = true as AnyObject
            }
            
            dict["special_instructions"] = self.specialInstruction.encodeEmoji
         
           addWashSetting(param: dict as [String : AnyObject])
            
        } else {
            presentAlert(title: nil, message: "Please select the options.")
        }
    }
    
    fileprivate func addWashSetting(param : [String : AnyObject]) {
        
        showLoadSpinner(message: "Updating Settings ...")
        
        let api = WashSettingNetworkModel()
        api.addWashSettings(param: param as [String : AnyObject]) { (success, result, error) in
            //  debugPrint(result)
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                
                if success {
                    
                    let message = result?["message"] as? String
                    
                    if result?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                appDel.switchToLogin()
                            }
                        })
                        
                    } else if result?["status"] as? Int == 200 {
                        
                        if strongSelf.isloginFlow {
                            //(UIApplication.shared.delegate as? AppDelegate)?.switchToDashboard()
                            strongSelf.finalStepWashSetting()
                        } else {
                            
                            strongSelf.presentAlert(title: nil, message: message ?? "Updated Successfully", completion: { (status) in
                               strongSelf.navigationController?.popViewController(animated: true)
                            })
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
    
    fileprivate func finalStepWashSetting() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegWashSettingListVC") as? WashSettingListViewController
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc fileprivate func updateFabricStatus(sender : UIButton) {
        
        sender.isSelected = !sender.isSelected
        useFabricSoftner = sender.isSelected
    }
    
}

extension CustomSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height: CGFloat = 0
        
        switch indexPath.section {
        case TableSection.Wash.rawValue:
            height = 100
        case TableSection.DryOption.rawValue:
            height = 110
        case TableSection.Detergent.rawValue:
            height = 60
        default:
            height = 110
            
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let identifier = (indexPath.section == 0) ? "CustomSettingCell" : "CustomSettingCell" + "\(indexPath.section)"
        
         let identifier = "CustomSettingCell" + "\(indexPath.section + 1)"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CustomSettingCell
        
        cell?.selectHandler = { [weak self] selectedKey in

            guard  let strongSelf = self else {
                return
            }

            strongSelf.selectedList[indexPath.section] = selectedKey
        }
        
        if cell?.checkBtn != nil {
            cell?.checkBtn.isSelected = useFabricSoftner
            cell?.checkBtn.addTarget(self, action: #selector(updateFabricStatus), for: UIControl.Event.touchUpInside)
        }
        
        if cell?.customTextView != nil {
            
            if cell?.customTextView.textView.inputAccessoryView == nil {
                
                let bar = UIToolbar()
                let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
                bar.items = [flexBarButton,done]
                bar.sizeToFit()
                cell?.customTextView.textView.inputAccessoryView = bar
                
                if specialInstruction.count != 0 {
                    cell?.customTextView.textViewDesc = specialInstruction
                }
                
                cell?.customTextView.selectHandler = { text, tag in
                    self.specialInstruction = text
                }
                
            }
        } else {
            
            if let keys = selectedKeys {
                cell?.updateButtonStatus(keyList: keys)
            }
        }
        
        return cell!
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
}

extension CustomSettingsViewController: UITextViewDelegate {
        
    @objc func doneAction() {
        resetTableViewScroll()
    }
    
    fileprivate func resetTableViewScroll() {
        
        self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.endEditing(true)
    }
}
