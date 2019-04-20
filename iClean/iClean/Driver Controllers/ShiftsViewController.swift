//
//  ShiftsViewController.swift
//  iClean
//
//  Created by Anand on 06/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class ShiftsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var placeHolder: UILabel!
    @IBOutlet weak var nextCustomerBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    
    fileprivate let lightGreenColor = UIColor(red: 76.0/255.0, green: 222.0/255.0, blue: 168.0/255.0, alpha: 1.0)
    fileprivate let creamWhiteColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 248.0/255.0, alpha: 1.0)
    
    var selectedRow : Int = 0
    var selectedSection : Int = 0
    
    fileprivate var shiftList: [Shifts]? = []
    fileprivate let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl.addTarget(self, action: #selector(fetchOrders), for: .valueChanged)
        self.tableview.insertSubview(self.refreshControl, at: 0)
        
        tableview.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchOrders()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        (UIApplication.shared.delegate as? AppDelegate)?.switchToLogin()
    }
    
    @objc fileprivate func fetchOrders() {
        
        showLoadSpinner(message: "Fetching Orders ...")
        let api = DriverNetworkModel()
        api.getOrder { (success, response, error) in
            
            debugPrint(response)
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                strongSelf.refreshControl.endRefreshing()
                
                if success {
                    
                    let message = response?["message"] as? String
                    
                    if response?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                appDel.switchToLogin()
                            }
                        })
                        
                    } else if response?["status"] as? Int == 200 {
                        
                        strongSelf.shiftList?.removeAll()
                        
                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            for keys in innerData.keys {
                                
                                if let list = innerData[keys] as? [String : AnyObject] {
                                    
                                    for key in list.keys {
                                        
                                        let object = list[key]
                                        let shift = Shifts(with: object as! [AnyObject])
                                        
                                        let timeSlot = key.lowercased().replacingOccurrences(of: "_to_", with: " - ", options: .literal, range: nil)
                                        
                                        shift.shiftDate = keys.lowercased().replacingOccurrences(of: "_to_", with: " - ", options: .literal, range: nil)
                                        
                                        shift.shiftDate = shift.shiftDate! + " " + timeSlot
                                        strongSelf.shiftList?.append(shift)
                                    }
                                    
                                    
                                }
                            }
                            
                            let list = strongSelf.shiftList?.sorted(by: { (obj1, obj2) -> Bool in
                                
                                guard let fName = obj1.shiftDate else { return false }
                                guard let sName = obj2.shiftDate else { return true }
                                
                                return fName < sName
                            })
                            
                            strongSelf.shiftList = list
                            
                            strongSelf.tableview.reloadData()
                            
                        }
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                        
                    }
                } else {
                    
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                    
                }
            })
        }
    }
    
    @IBAction func nextCustomerAction(_ sender: Any) {
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "NextCustUpdatesVC") as? NextCustUpdatesViewController
        nextVC?.order = shiftList?[0].list[0]
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let count = self.shiftList?.count ?? 0
        self.placeHolder.isHidden = count == 0 ? false : true
        self.nextCustomerBtn.isHidden = count == 0 ? true : false
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let shift = shiftList?[section]
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
        label.backgroundColor = UIColor.white
        label.textColor = UIColor(red: 76.0/255.0, green: 222.0/255.0, blue: 168.0/255.0, alpha: 1.0)
        label.text = "   " + (shift?.shiftDate ?? "")
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        return label
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftList?[section].list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shiftCell")
        cell?.backgroundColor = creamWhiteColor
        cell?.textLabel?.textColor = UIColor.black
        cell?.detailTextLabel?.textColor = UIColor.black
        
        let orderInfo = shiftList?[indexPath.section].list[indexPath.row]
        
        cell?.detailTextLabel?.text = "#\(orderInfo?.ordInfo?.uid ?? "") - \(orderInfo?.typeStr?.capitalized ?? "")"
        
        cell?.textLabel?.text = "\(orderInfo?.customer?.name?.capitalized ?? "")"
        
        if selectedRow == indexPath.row && selectedSection == indexPath.section {
            cell?.backgroundColor = lightGreenColor
            cell?.textLabel?.textColor = UIColor.white
            cell?.detailTextLabel?.textColor = UIColor.white
            
        }
        
        return cell!
    }
    
    
    //Commit this code if we need to select always the first index
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "NextCustUpdatesVC") as? NextCustUpdatesViewController
        nextVC?.order = shiftList?[indexPath.section].list[indexPath.row]
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
    }
    
    
}
