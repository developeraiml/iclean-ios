//
//  OrderReceiptCell.swift
//  iClean
//
//  Created by Anand on 05/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderReceiptCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var tipAmount : String? = "0"
    var tipHandler : ((_ didSelect: Bool)->Void)?
    
    var totalAmount : Double = 0.0
    var discount : Double = 0.0
    
    var cardInfo: Card?
    
    var itemList: [Item] = [] {
        
        didSet{
          //  totalAmount = itemList.reduce(0, { $0 + ($1.totalAmount ?? 0.0)})
            self.collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension OrderReceiptCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? (itemList.count) : 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemReceiptCell", for: indexPath) as? ItemReceiptCell
            
            let itm = itemList[indexPath.row]
            
            cell?.itemNameLbl.text = "\(itm.qty ?? 0) \(itm.itemName ?? "")"
            cell?.itemPrice.text =  "$" + "\(itm.totalAmount ?? 0.0)"
            
            return cell!
            
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemReceiptTipCell", for: indexPath) as? ItemReceiptTipCell
            
            cell?.addTipLbl.text = "Add Tip"
            cell?.tipAmount.text = ""
            
            let tipAmt = Double(tipAmount ?? "0")

            if tipAmt != 0 {
                cell?.addTipLbl.text = "Tip"
                cell?.tipAmount.text =  String(format: "$%0.2f", tipAmt ?? 0.0)
            }
            
            return cell!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemReceiptAmountCell", for: indexPath) as? ItemReceiptAmountCell
            
            let tipAmt = Double(tipAmount ?? "0")

            cell?.totalAmount.text = String(format: "$%0.2f",((tipAmt ?? 0.0) + totalAmount))
            
            if discount != 0 {
                cell?.totalLbl.text = String(format: "Total (Discount of $%0.2f)", discount) 
            }
            
            if let card = cardInfo {
                cell?.cardNumber.text = "XXXX-XXXX-XXXX-\(card.cardNumber ?? "")"
                cell?.cardType.text = card.companyName
            }
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            if let handler = tipHandler {
                handler(true)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height : CGFloat = indexPath.section == 2 ? 110.0 : 50.0
        
        return CGSize(width: collectionView.frame.size.width, height: height)
    }
    
}
