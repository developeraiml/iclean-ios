//
//  ContactUsVC.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class ContactUsViewController: BaseViewController {

    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchContact()
    }
    
    fileprivate func fetchContact(){
        
        showLoadSpinner(message: "Loading Contact ...")
        let api = OthersNetworkModel()
        api.fetchContact { (success, response, error) in
            
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
                            
                            let attributedString = NSMutableAttributedString(string: (innerData["contact_phone"] as? String) ?? "(424)294-2222", attributes: [
                                .font: UIFont(name: "HelveticaNeue-Medium", size: 18.0)!,
                                .foregroundColor: UIColor(white: 114.0 / 255.0, alpha: 1.0),
                                .underlineStyle: NSUnderlineStyle.single.rawValue
                                ])
                            
                            strongSelf.phoneBtn.setAttributedTitle(attributedString, for: .normal)
                            
                            let attributedString1 = NSMutableAttributedString(string: (innerData["contact_email"] as? String) ?? "support@joiniclean.com", attributes: [
                                .font: UIFont(name: "HelveticaNeue-Medium", size: 18.0)!,
                                .foregroundColor: UIColor(white: 114.0 / 255.0, alpha: 1.0),
                                .underlineStyle: NSUnderlineStyle.single.rawValue
                                ])
                            
                            strongSelf.emailBtn.setAttributedTitle(attributedString1, for: .normal)
                           
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

    
    @IBAction func phoneAction(_ sender: UIButton) {
        
        let phoneString = sender.titleLabel?.attributedText?.string
        
        if let url = URL(string: "tel://\(phoneString?.replacingOccurrences(of: " ", with: "") ?? "4242942222")") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
        
    }
    
    @IBAction func emailAction(_ sender: UIButton) {
        
        let email = sender.titleLabel?.text
        if let url = URL(string: "mailto:\(email ?? "support@joiniclean.com")") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
