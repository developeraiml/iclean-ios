//
//  OthersNetworkModel.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import Foundation

class OthersNetworkModel: ApiNetwork {

    func fetchFAQ(handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        get("customer-service/faqs/", completed: handler)
    }
    
    func fetchPrice(handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        get("customer-service/prices/", completed: handler)
    }
    
    func fetchContact(handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        get("customer-service/get-iclean-contact/", completed: handler)
    }
    
    func getPromo(handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        get("user/share-promo/?type=1", completed: handler)
    }
    
    func updateEmail(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/change-email/", postCompleted: handler)
    }
    
    func updatePassword(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/change-password/", postCompleted: handler)
    }
}
