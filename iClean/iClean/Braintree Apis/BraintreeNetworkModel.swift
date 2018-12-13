//
//  BraintreeNetworkModel.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class BraintreeNetworkModel: ApiNetwork {
    
    func fetchBrainTreeToken(handler: @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        get("user/get-client-token/", completed: handler)
    }
    
    func addCard(_ nonce: String,_ handler: @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        post(["nonce": nonce as AnyObject], path: "user/add-card/", postCompleted: handler)
    }
    
    func getAllCards(handler: @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        get("user/get-cards/", completed: handler)
    }
    
    func updateCard(_ dict : [String: AnyObject],_ handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        put(dict, path: "user/update-card/", postCompleted: handler)
    }
}
