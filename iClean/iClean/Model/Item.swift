//
//  Item.swift
//  iClean
//
//  Created by Anand on 04/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class Item: NSObject {
    
    var itemName: String?
    var cost: String?
    var tId: Int?
    
    var qty: Int?
    var totalAmount: Double?
    var additionalFee: Double?
    var addFeeDesc: String?
    var orderId: Int?
    
     init(with object : [String: AnyObject]) {
        
        if let ouid = object["order_id"] as? Int {
            orderId = ouid
        }
        
        if let price = object["price"] as? Double {
            cost = "\(price)"
        }
        
        if let quantity = object["quantity"] as? Int {
            qty = quantity
        }
        
        if let item_name = object["item_name"] as? String {
            itemName = item_name
        }
        
        if let amount = object["amount"] as? Double {
            totalAmount = amount
        }
        
        if let additional_fee_description = object["additional_fee_description"] as? String {
            addFeeDesc = additional_fee_description
        }
        
        if let additional_fee = object["additional_fee"] as? Double {
            additionalFee = additional_fee
        }
        
    }

}
