//
//  driverOrder.swift
//  iClean
//
//  Created by Anand on 07/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class driverOrder: NSObject {

    var address: UserAddress?
    var customer: Customer?
    var ordInfo : order?
    var type : orderStatus?
    var typeStr : String?
    
    init(with orderInfo : [String: AnyObject]) {
        
        if let cust = orderInfo["customer"] as? [String : AnyObject] {
            customer = Customer(with: cust)
        }
        
        if let addres = orderInfo["address"] as? [String : AnyObject] {
            address  = UserAddress(with: addres)
        }
        
        if let item = orderInfo["order"] as? [String : AnyObject] {
            ordInfo = order(with: item)
        }
        
        if let status = orderInfo["type"] as? String {
            typeStr = status
            type = orderStatus(rawValue: status) ?? .OrderPlaced
        }
    }
    
}
