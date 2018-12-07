//
//  Card.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class Card: NSObject {

    var companyName : String?
    var cardId : Int?
    var expiry : String?
    var cardNumber: String?
    var nickName: String?
    var name : String?
    
    init(with object : [String: AnyObject]) {
        
        
        if let ouid = object["id"] as? Int {
            cardId = ouid
        }
        
        if let nick = object["company"] as? String {
            companyName = nick
        }
        
        if let nick = object["name"] as? String {
            name = nick
        }
        
        if let nick = object["nickname"] as? String {
            nickName = nick
        }
        
        if let exp = object["expiry"] as? String {
            expiry = String(exp.suffix(7))
        }
        
        if let number = object["number"] as? Int {
            cardNumber = "\(number)"
        }
        
        if let number = object["card_number"] as? Int {
            cardNumber = "\(number)"
        }
        
        
    }
}
