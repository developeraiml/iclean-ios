//
//  PriceListViewController.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class PriceListViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    fileprivate var priceList : [price] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableview.tableFooterView = UIView()
        
        fetchPriceList()
    }
    
    fileprivate func fetchPriceList(){
        
        showLoadSpinner(message: "Loading Price ...")
        let api = OthersNetworkModel()
        api.fetchPrice { (success, response, error) in
            
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
                        
                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            for fqa in (innerData["prices"] as? [[String: AnyObject]])! {
                                
                                let obj = price(with: fqa)
                                
                                strongSelf.priceList.append(obj)
                            }
                            
                            strongSelf.tableview.reloadData()
                        }
                    }
                    else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                        
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                    
                }
            })
        }
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.priceCell)
        
        let price = self.priceList[indexPath.row]
        
        cell?.textLabel?.text = price.item_name?.capitalized
        cell?.detailTextLabel?.text = "$\(price.price)"
        
        return cell!
    }

}
