//
//  HomeWashSettingVC.swift
//  iClean
//
//  Created by Anand on 28/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class HomeWashSettingVC: BaseViewController {

    fileprivate var rowSelected : Int = -1
    fileprivate var selectedKeys : [String] = []
    fileprivate var specialInstruction : String = ""
    
    fileprivate var dressList = ["","",""]
    fileprivate var noOfSection : Int = 2

    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        fetchWashSettings()

    }
    
    
    fileprivate func getDictParams() -> [String: Any] {
        
        let dict = ["is_iclean_recommended": false, "package_boxed" : false, "package_hanger" : false,
                    "starch_heavy" : false, "starch_medium" :false , "starch_light" : false , "starch_none" : false,
                    "clean_we_decide" : false, "clean_laundry" : false, "clean_dry_clean" : false]
        
        return dict
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        if self.rowSelected == 1 {
            let list = dressList.filter({$0 == ""})
            if list.count == 0 {
                
                var dict = getDictParams()
                dict["is_iclean_recommended"] = false
                
                //var dict: [String: Any] = ["is_iclean_recommended": false]
                for sKey in dressList {
                    dict[sKey] = true as AnyObject
                }
                
                dict["special_instructions"] = self.specialInstruction.encodeEmoji
                addWashSetting(param: dict as [String : AnyObject])
                
            } else {
                presentAlert(title: nil, message: "Please select the options.")
            }
        } else {
            let dict: [String: Any] = ["is_iclean_recommended": true]
            addWashSetting(param: dict as [String : AnyObject])

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
                    
                    if result?["status"] as? Int == 200 {
                        
                        strongSelf.presentAlert(title: nil, message: message ?? "Updated Successfully", completion: { (status) in
                            strongSelf.navigationController?.popViewController(animated: true)
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
    
    fileprivate func fetchWashSettings() {
        
        showLoadSpinner(message: "Loading ...")
        
        let api = WashSettingNetworkModel()
        api.fetchWashSettings { (success, result, error) in
            
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
                        
                         if let innerData = result?["data"] as? [String: AnyObject] {
                            
                            if let isRecommended = innerData["is_iclean_recommended"] as? Bool {
                                strongSelf.rowSelected = isRecommended ? 0 : 1
                                strongSelf.noOfSection = 1
                                
                                if isRecommended == false {
                                    strongSelf.noOfSection = 2
                                }
                            }
                            
                            if let instruction = innerData["special_instructions"] as? String {
                                strongSelf.specialInstruction = instruction.decodeEmoji
                            }
                            
                            strongSelf.selectedKeys.removeAll()

                            for key in innerData.keys {
                                
                                if key != "is_iclean_recommended" {
                                    
                                    if let keyStatus = innerData[key] as? Bool, keyStatus == true {
                                        strongSelf.selectedKeys.append(key)
                                    }
                                }
                            }
                        }
                        
                      //  debugPrint(strongSelf.selectedKeys)
                        strongSelf.tableview.reloadData()
                        
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                    
                }
            })
        }
    }
    
    @objc fileprivate func tickButtonAction(sender : UIButton) {
        
        rowSelected = sender.tag
        noOfSection = rowSelected == 0 ? 1 : 2
        self.tableview.reloadData()
    }

}

extension HomeWashSettingVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        label.text = (section == 0) ? "Wash and Fold" : "Dress Shirt preference"
        label.textColor = UIColor(red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 1.0)
        label.font =  UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.white
        label.textAlignment = .center
        
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.noOfSection
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 0) ? 84.0 : 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let identifier = (indexPath.row == 0) ? "HomeWashCell" : "HomeWashCell1"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WashSettingsCell
            
            cell?.infoButton.addTarget(self, action: #selector(openPopView), for: .touchUpInside)
            
            cell?.tickBtn.addTarget(self, action: #selector(tickButtonAction), for: .touchUpInside)
            
            cell?.tickBtn.tag = indexPath.row
            
            cell?.tickBtn.isSelected = false
            if indexPath.row == rowSelected {
                cell?.tickBtn.isSelected = true
            }
            return cell!
        } else {
            
            let identifier = (indexPath.row == 0) ? "HomeWashSetting" : "HomeWashSetting" + "\(indexPath.row)"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CustomSettingCell
            
            cell?.updateButtonStatus(keyList: selectedKeys)
            
            cell?.selectHandler = { [weak self] selectedKey in
                
                guard  let strongSelf = self else {
                    return
                }
                
                strongSelf.dressList[indexPath.row] = selectedKey
            }
            
            return cell!
        }    
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell: WashSettingsCell = tableView.cellForRow(at: indexPath) as? WashSettingsCell {
            cell.tickBtn.isSelected = true
          //  rowSelected = indexPath.row
            tableView.reloadData()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            openCustomSettings()
        }
    }

}

extension HomeWashSettingVC {
    
    func openCustomSettings() {
        guard let customVC = storyboard?.instantiateViewController(withIdentifier: "CustomSettingsVC") as? CustomSettingsVC else {
            return
        }
        customVC.selectedKeys = selectedKeys
        customVC.specialInstruction = self.specialInstruction
        self.navigationController?.pushViewController(customVC, animated: true)
    }
    
    @objc func openPopView() {
        
        showPopView(popupType: .Info) { (onSuccess) in
            
        }
    }
}
