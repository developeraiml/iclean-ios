//
//  Faq.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import Foundation

class Faq: NSObject {

    var answer: String?
    var question: String?
    var uid: String?
    
    init(with object : [String: AnyObject]) {
        if let oid = object["question"] as? String {
            question = oid
        }
        
        if let ouid = object["id"] as? Int {
            uid = "\(ouid)"
        }
        
        if let nick = object["answer"] as? String {
            answer = nick
        }
        
    }
}
