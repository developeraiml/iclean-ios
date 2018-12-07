//
//  OrderPromoCell.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderPromoCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var promoCode: UITextField!
    
    var didBeginEditing: ((Bool)->Void)?
    var didEndEditing : ((_ text:  String)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if let handler = didBeginEditing {
            handler(true)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let handler = didEndEditing {
            handler(textField.text ?? "")
        }
    }

}
