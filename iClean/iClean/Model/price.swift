//
//  price.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import Foundation

class price: NSObject {
    
    var price: Double = 0
    var item_name: String?
    var uid: String?
    
    init(with object : [String: AnyObject]) {
        
        if let oid = object["price"] as? Double {
            price = oid
        }
        
        if let ouid = object["id"] as? Int {
            uid = "\(ouid)"
        }
        
        if let nick = object["item_name"] as? String {
            item_name = nick
        }
        
    }
}
