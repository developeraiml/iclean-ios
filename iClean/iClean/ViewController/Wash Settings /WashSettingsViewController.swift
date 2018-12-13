//
//  WashSettingsVC.swift
//  iClean
//
//  Created by Anand on 17/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class WashSettingsViewController: BaseViewController {
    
    fileprivate var rowSelected : Int = -1

    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if rowSelected == 0 {
            
            showLoadSpinner(message: "Storing Settings ...")
            
            let api = WashSettingNetworkModel()
            api.addWashSettings(param: ["is_iclean_recommended": true] as [String : AnyObject]) { (success, result, error) in
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
            
        } else if rowSelected == 1 {
                openCustomSettings()
        } else {
            presentAlert(title: nil, message: "Please select wash setting option")
        }

    }
    
    func openCustomSettings() {
        guard let customVC = storyboard?.instantiateViewController(withIdentifier: "RegCustomSettingsVC") as? CustomSettingsViewController else {
            return
        }
        customVC.isloginFlow = true
        self.navigationController?.pushViewController(customVC, animated: true)
    }
    
    @objc func openPopView() {
        showCustomPopView(popupType: .Info, title: "iClean recommended wash is cold wash and medium dry.", customBtnTitle: "OKAY") { (onSuccess) in
            
        }
    }
    
    
    @IBAction func skipAction(_ sender: Any) {
        
        (UIApplication.shared.delegate as! AppDelegate).switchToDashboard()
    }
    
    @objc func tickMarkAction(sender: UIButton){
        rowSelected = sender.tag
        self.tableview.reloadData()
    }
}

extension WashSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = (indexPath.section == 0) ? "WashSettingsCell" : "WashSettingsCell1"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WashSettingsCell
        
        cell?.infoButton.addTarget(self, action: #selector(openPopView), for: .touchUpInside)
        cell?.tickBtn.addTarget(self, action: #selector(tickMarkAction), for: .touchUpInside)
        
        cell?.tickBtn.tag = indexPath.section
        cell?.tickBtn.isSelected = false
        
        if indexPath.section == rowSelected {
            cell?.tickBtn.isSelected = true
        }
        
        return cell!
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell: WashSettingsCell = tableView.cellForRow(at: indexPath) as? WashSettingsCell {
            cell.tickBtn.isSelected = true
            rowSelected = indexPath.section
            tableView.reloadData()
        }
        
        if indexPath.section == 1 {
          openCustomSettings()
        }
    }
    
}
