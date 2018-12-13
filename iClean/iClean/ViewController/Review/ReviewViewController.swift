//
//  ReviewViewController.swift
//  iClean
//
//  Created by Anand on 05/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class ReviewViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    
    var orderDetials :order?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateRating(rating: orderDetials?.rating ?? 0)
        
        tableview.tableFooterView = UIView()
    }
    
    
    fileprivate  func updateRating(rating : Int) {
        
        guard let views = (stackView.arrangedSubviews as? [UIButton]) else {
            return
        }
        
        for view in views {
            
            view.isSelected = false
            
            if rating >= view.tag {
                view.isSelected = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.section == 0 ? 88.0 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cardCell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.reviewCardCell) as? ReviewCardCell
                
                cardCell?.cardNumber.text = "xxxx-xxxx-xxx-\(orderDetials?.cardInfo?.cardNumber ?? "")"
                cardCell?.totalAmount.text = "$\((orderDetials?.orderCost ?? 0.0) + (orderDetials?.tipAmount ?? 0.0))"
                
                return cardCell!
            } else {
                let tipCell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.reviewTipCell) as? ReviewTipsCell
                
                tipCell?.orderAmount.text = "$\(orderDetials?.totalAmount ?? 0.0)"
                tipCell?.tipAmount.text = "$\(orderDetials?.tipAmount ?? 0.0)"
                tipCell?.discountAmount.text = "-$\(orderDetials?.discount ?? 0.0)"

                return tipCell!

            }
        
        } else if indexPath.section == 1 {
            
            let pickCell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.reviewCell) as? OrderDetailsCell
            
            pickCell?.pickTypeLbl.text = (indexPath.row == 0) ? "PICK UP" : "DROP OFF"
            pickCell?.pickDate.text = (indexPath.row == 0) ? orderDetials?.pickupDate : orderDetials?.dropOffDate
            
            if let address = (indexPath.row == 0) ? orderDetials?.pickupLocation : orderDetials?.dropOffLocation {
                
                 pickCell?.pickAddress.text = "\(address.address_1 ?? ""), \(address.apartment_name ?? ""), \(address.gate_code ?? ""), \(address.city ?? ""), \(address.state ?? "") \(address.zip_code ?? "")"
            }
            
            return pickCell!
        } else {
            let washCell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.reviewWashSettingCell) as? FaqTableViewCell
            
            washCell?.faqTtitle.text = (indexPath.row == 0) ? "WASH SETTINGS" : "REVIEW"
            washCell?.faqDesc.text = (indexPath.row == 0) ? orderDetials?.washSetting : orderDetials?.userReview
            
            return washCell!
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    

}
