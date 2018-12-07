//
//  UserAddress.swift
//  iClean
//
//  Created by Anand on 28/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

@objcMembers
class UserAddress: NSObject {

    var nickname: String?
    var userid: String?
    var uid: String?
    var address_1: String?
    var apartment_name: String?
    var gate_code: String?
    var city: String?
    var state: String?
    var zip_code: String?
    var leaveAtDoorman: Bool = false

    
    override init() {
        super.init()
    }
    
     init(with object : [String: AnyObject]) {
        if let oid = object["user_id"] as? String {
            userid = oid
        }
        
        if let ouid = object["id"] as? Int {
             uid = "\(ouid)"
        }
        
        if let nick = object["nickname"] as? String {
            nickname = nick.decodeEmoji
        }
        
        if let adrs = object["address_1"] as? String {
            address_1 = adrs.decodeEmoji
        }
        
        if let apart = object["apartment_name"] as? String {
            apartment_name = apart.decodeEmoji
        }
        
        if let gate = object["gate_code"] as? String {
            gate_code = gate.decodeEmoji
        }
        
        if let cty = object["city"] as? String {
            city = cty.decodeEmoji
        }
        
        if let sat = object["state"] as? String {
            state = sat.decodeEmoji
        }
        
        if let zip = object["zip_code"] as? String {
            zip_code = zip.decodeEmoji
        }
        
        if let door = object["leave_with_doorman"] as? Bool {
            leaveAtDoorman = door
        }
    }
}
