//
//  WashSettingListVC.swift
//  iClean
//
//  Created by Anand on 18/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class WashSettingListVC: BaseViewController {
    
    fileprivate var selectedList = ["","",""]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func doneAction(_ sender: Any) {
      //  debugPrint(selectedList.filter({$0 == ""}))
        
        let list = selectedList.filter({$0 == ""})
        if list.count == 0 {
            
            var dict: [String: Any] = ["is_iclean_recommended": false]
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
                            
                            (UIApplication.shared.delegate as? AppDelegate)?.switchToDashboard()
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


extension WashSettingListVC: UITableViewDataSource, UITableViewDelegate {
    
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
        
        return cell!
        
    }
    
}
