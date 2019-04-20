//
//  MenuViewController.swift
//  iClean
//
//  Created by Anand on 20/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    enum menuType : Int {
        case orderHistory
        case washSettings
        case myCard
        case myLocation
        case ourPricing
        case changeEmail
        case changePassword
        case FAQ
        case contact
        case logout
    }
    
    enum smMenuType : Int {
        case orderHistory
        case washSettings
        case myCard
        case myLocation
        case ourPricing
        case FAQ
        case contact
        case logout
    }

    @IBOutlet weak var tableTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableview: UITableView!
    
      fileprivate var menuList = [["name" : "ORDER HISTORY", "image" : "icnHistory"],
                                  ["name" : "WASH SETTINGS", "image" : "icnWashSettings"],
                                  ["name" : "MY CARD", "image" : "icnMyCard"],
                                  ["name" : "MY LOCATIONS", "image" : "icnMyLocations"],
                                  ["name" : "PRICING", "image" : "icnDollar"],
                                  ["name" : "CHANGE E-MAIL", "image" : "icnChangeEmail"],
                                  ["name" : "CHANGE PASSWORD", "image" : "icnChangePassword"],
                                  ["name" : "FAQ", "image" : "icnFaq"],
                                  ["name" : "CONTACT iClean", "image" : "icnSupport"],
                                  ["name" : "LOGOUT", "image" : "icnLogout"]]
    
    fileprivate var smMenuList = [["name" : "ORDER HISTORY", "image" : "icnHistory"],
                                ["name" : "WASH SETTINGS", "image" : "icnWashSettings"],
                                ["name" : "MY CARD", "image" : "icnMyCard"],
                                ["name" : "MY LOCATIONS", "image" : "icnMyLocations"],
                                ["name" : "PRICING", "image" : "icnDollar"],
                                ["name" : "FAQ", "image" : "icnFaq"],
                                ["name" : "CONTACT iClean", "image" : "icnSupport"],
                                ["name" : "LOGOUT", "image" : "icnLogout"]]
    
    fileprivate var menu : menuType = .orderHistory
    fileprivate var isLoggedSM : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let _ = UserDefaults.standard.object(forKey: "isFbGL") {
           isLoggedSM = true
        }
        
    }
    
    func resetAnimation() {
        tableTrailingConstraint.constant = UIScreen.main.bounds.size.width
        self.view.layoutIfNeeded()
        animateOnOpen()
    }
    

    func animateOnOpen() {
        
        tableTrailingConstraint.constant = 100
        UIView.animate(withDuration: 0.4) {
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        tableTrailingConstraint.constant = UIScreen.main.bounds.size.width
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
        }) { (success) in
            self.closeMenu()
        }
    }
    
    func closeMenu() {
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoggedSM == true ? smMenuList.count : menuList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.menuCell) as? MenuCell
        
        let list = isLoggedSM == true ? smMenuList[indexPath.row] : menuList[indexPath.row]
        
        cell?.menuImage.image = UIImage(named: list["image"]!)
        cell?.menuText.text = list["name"] ?? ""
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if isLoggedSM == true {
            
            switch indexPath.row {
                
            case smMenuType.ourPricing.rawValue:
                showPriceList()
            case smMenuType.orderHistory.rawValue:
                showOrderHistory()
            case smMenuType.myLocation.rawValue:
                showLocationList()
            case smMenuType.washSettings.rawValue:
                showWashSettings()
            case smMenuType.myCard.rawValue:
                showCards()
            case smMenuType.contact.rawValue:
                showContactUs()
            case smMenuType.FAQ.rawValue:
                showFAQ()
            case smMenuType.logout.rawValue:
                (UIApplication.shared.delegate as? AppDelegate)?.switchToLogin()
            default:
                break
            }
            
        } else {
            
            switch indexPath.row {
            case menuType.orderHistory.rawValue:
                showOrderHistory()
            case menuType.myLocation.rawValue:
                showLocationList()
            case menuType.ourPricing.rawValue:
                showPriceList()
            case menuType.washSettings.rawValue:
                showWashSettings()
            case menuType.myCard.rawValue:
                showCards()
            case menuType.contact.rawValue:
                showContactUs()
            case menuType.FAQ.rawValue:
                showFAQ()
            case menuType.changeEmail.rawValue:
                showChangeEmail()
            case menuType.changePassword.rawValue:
                showChangePassword()
            case menuType.logout.rawValue:
                (UIApplication.shared.delegate as? AppDelegate)?.switchToLogin()
            default:
                break
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.closeMenu()
        }
      
    }
    
    fileprivate func showPriceList() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier:"PriceListViewController") as? PriceListViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func showOrderHistory() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.orderHistoryVC) as? OrderHistoryViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func showWashSettings() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.homeWashSettingVC) as? HomeWashSettingViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func showLocationList() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.locationListVC) as? LocationListViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func showCards() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.cardListVC) as? CardListViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func showContactUs() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.contactusVC) as? ContactUsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func showFAQ() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.faqVC) as? FAQViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func showChangeEmail() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.changeEmailPasswordVC) as? ChangeEmailPasswordViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func showChangePassword() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.changeEmailPasswordVC) as? ChangeEmailPasswordViewController
        vc?.isChangeEmailScreen = false
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    //AddCardVC
}
