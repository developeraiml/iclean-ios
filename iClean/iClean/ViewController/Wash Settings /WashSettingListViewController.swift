//
//  WashSettingListVC.swift
//  iClean
//
//  Created by Anand on 18/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class WashSettingListViewController: BaseViewController {
    
    fileprivate var selectedList = ["","",""]
    var selectedKeys : [String]?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    fileprivate func getDictParams() -> [String: Any] {
        
        let dict = ["is_iclean_recommended": false, "package_boxed" : false, "package_hanger" : false,
                    "starch_heavy" : false, "starch_medium" :false , "starch_light" : false , "starch_none" : false,
                    "clean_we_decide" : false, "clean_laundry" : false, "clean_dry_clean" : false]
        
        return dict
    }

    

    @IBAction func doneAction(_ sender: Any) {
      //  debugPrint(selectedList.filter({$0 == ""}))
        
        let list = selectedList.filter({$0 == ""})
        if list.count == 0 {
            
            var dict = getDictParams()
            //var dict: [String: Any] = ["is_iclean_recommended": false]
            dict["is_iclean_recommended"] = false
            
            for sKey in selectedList {
                dict[sKey] = true as AnyObject
            }
            
            showLoadSpinner(message: "Storing Settings ...")
            
            let api = WashSettingNetworkModel()
            api.addWashSettings(param: dict as [String : AnyObject]) { (success, result, error) in
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
                            if strongSelf.selectedKeys != nil {
                                if let vc = strongSelf.navigationController?.children[1] {
                                    strongSelf.navigationController?.popToViewController(vc, animated: true)
                                }
                            } else {
                                (UIApplication.shared.delegate as? AppDelegate)?.switchToDashboard()

                            }
                        } else {
                            strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                        }
                    } else {
                        strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")

                    }
                })
                
            }
            
            
        } else {
            presentAlert(title: nil, message: "Please select the options.")
        }
    }
}


extension WashSettingListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = (indexPath.section == 0) ? "washSetting" : "washSetting" + "\(indexPath.section)"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CustomSettingCell

        cell?.selectHandler = { [weak self] selectedKey in
            
            guard  let strongSelf = self else {
                return
            }
            
            strongSelf.selectedList[indexPath.section] = selectedKey
            //debugPrint(strongSelf.selectedList)
        }
        
        
        if let keys = selectedKeys {
            cell?.updateButtonStatus(keyList: keys)
        }
        
        
        return cell!
        
    }
    
}
