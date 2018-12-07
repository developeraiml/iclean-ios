//
//  FAQViewController.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class FAQViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableview: UITableView!
    
    fileprivate var faqList: [Faq] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchFAQ()
    }
    
    fileprivate func fetchFAQ() {
        
          showLoadSpinner(message: "Loading FAQ ...")
        let api = OthersNetworkModel()
        api.fetchFAQ { (success, response, error) in
            
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
                            
                            for fqa in (innerData["faqs"] as? [[String: AnyObject]])! {
                                
                                let obj = Faq(with: fqa)
                                
                                strongSelf.faqList.append(obj)
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
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return faqList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaqTableViewCell") as? FaqTableViewCell
        let faqObj = faqList[indexPath.row]
        
        cell?.faqTtitle.text = faqObj.question
        cell?.faqDesc.text = faqObj.answer
        
        return cell!
    }

}
