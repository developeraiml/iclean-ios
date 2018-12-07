//
//  Customer.swift
//  iClean
//
//  Created by Anand on 07/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class Customer: NSObject {

    var braintreeId : String?
    var email: String?
    var cId : String?
    var name : String?
    var phone: String?
    var userId : String?
    var zipCode : String?
    
    init(with object : [String: AnyObject]) {
        
        if let ouid = object["id"] as? Int {
            cId = "\(ouid)"
        }
        
        if let nick = object["user_id"] as? String {
            userId = nick
        }
        
        if let braintree_id = object["braintree_id"] as? Int64 {
            braintreeId = "\(braintree_id)"
        }
        
        if let emailObj = object["email"] as? String {
            email = emailObj
        }
        
        if let nam = object["name"] as? String {
            name = nam
        }
        
        if let phone_number = object["phone_number"] as? String {
            phone = phone_number
        }
        
        if let zip_code = object["zip_code"] as? Int {
            zipCode = "\(zip_code)"
        }
        
    }
}
