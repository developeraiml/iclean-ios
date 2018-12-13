//
//  HomeViewController.swift
//  iClean
//
//  Created by Anand on 20/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {

    @IBOutlet weak var tableview: UITableView!
    
    fileprivate var menuVC : MenuViewController?
    
    fileprivate var homeList = [["name" : "Place An Order", "image" : "icnNewOrder"],["name" : "Refer People,\nEarn Credit", "image" : "icnRefer"],["name" : "Order History", "image" : "icnOrderHistory"]]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableview.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        if !iCleanManager.sharedInstance.isBrainTreeTokenAvailable() {
            iCleanManager.sharedInstance.fetchBrainTreeToken()
        }
    }
    

    @IBAction func menuAction(_ sender: Any) {
        
        if menuVC == nil {
            menuVC = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.menuVC) as? MenuViewController
        }
        menuVC?.willMove(toParent: self)
        self.view.addSubview(menuVC!.view)
        self.addChild(menuVC!)
        menuVC!.didMove(toParent: self)
        menuVC?.resetAnimation()
        
    }
    

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.homeCell) as? HomeCell
        
        let list = homeList[indexPath.row]
        
        cell?.homeImageView.image = UIImage(named: list["image"]!)
        cell?.homeText.text = list["name"] ?? ""
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            showPlaceOrder()
        case 1:
            shareAppInfo()
        default:
            showOrderHistory()
        }
        
    }
}


extension HomeViewController {
    
    fileprivate func showOrderHistory() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.orderHistoryVC) as? OrderHistoryViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func showPlaceOrder() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.orderVC) as? OrderViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func shareAppInfo() {
        
        showLoadSpinner(message: "Fetching Promo ...")

        let api = OthersNetworkModel()
        api.getPromo { (success, response, error) in
            
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
                            
                            if let promoText = innerData["text"] as? String {
                                strongSelf.openActivityController(text: promoText)
                            }
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
    
    fileprivate func openActivityController(text : String) {
        
       // let image = UIImage(named: "avatar")
        let objectsToShare: [AnyObject] = [text as AnyObject]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]


        self.present(activityViewController, animated: true, completion: nil)
    }
}
