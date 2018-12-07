//
//  LocationNetworkModel.swift
//  iClean
//
//  Created by Anand on 23/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class LocationNetworkModel: ApiNetwork {

    func addAddress(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/address/", postCompleted: handler)
    }
    
    func updateAddress(param : [String: AnyObject],for addressId: String, handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        put(param, path: "user/address/\(addressId)/", postCompleted: handler)
    }
    
    func fetchAddress(handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        get("user/address/", completed: handler)
    }
    
    func deleteAddress(addressId: String, handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        delete("user/address/\(addressId)", completed: handler)
    }
}
