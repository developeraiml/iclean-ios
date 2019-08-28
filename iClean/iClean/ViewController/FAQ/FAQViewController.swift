//
//  FAQViewController.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class FAQViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    enum SectionType: Int {
        case orderFaq
        case serviceFaq
        case costFaq
        case deliveryFaq
        case policiesFaq
        
        var description: String {
            get {
                switch self {
                case .orderFaq:
                    return "Orders"
                case .serviceFaq:
                    return "Services"
                case .costFaq:
                    return "Costs"
                case .deliveryFaq:
                    return "Delivery"
                case .policiesFaq:
                    return "Policies"
                }
            }
        }
    }
    @IBOutlet weak var tableview: UITableView!
    
    //fileprivate var faqList: [Faq] = []
    fileprivate var faqLists: [Int: [Faq]] = [:]
    fileprivate var selectedSection: Int = -1
    
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
                                if let type = fqa["faq_type"] as? Int {
                                    if let _ = strongSelf.faqLists[type] {
                                        strongSelf.faqLists[type]?.append(obj)
                                    } else {
                                        strongSelf.faqLists[type] = [obj]
                                    }
                                    
                                }
                                
                                //strongSelf.faqList.append(obj)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return faqLists.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let list = faqLists[section + 1]
        return (selectedSection == section) ? list?.count ?? 0 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.faqCell) as? FaqTableViewCell
        
        let list = faqLists[indexPath.section + 1]
        let faqObj = list?[indexPath.row]
        
        cell?.faqTtitle.text = faqObj?.question
        cell?.faqDesc.text = faqObj?.answer
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.backgroundColor = UIColor.white
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 39))
        btn.setTitle("     \(SectionType(rawValue: section)?.description ?? "")", for: UIControl.State.normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        btn.tag = section
        btn.addTarget(self, action: #selector(didSectionSelect), for: UIControl.Event.touchUpInside)
        
        view.addSubview(btn)
        return view
    }
    
    @objc fileprivate func didSectionSelect(sender: UIButton) {
        
        if selectedSection != sender.tag {
            selectedSection = sender.tag
        } else {
            selectedSection = -1
        }
        tableview.reloadData()
    }

}
