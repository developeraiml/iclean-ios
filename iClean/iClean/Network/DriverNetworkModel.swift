//
//  DriverNetworkModel.swift
//  iClean
//
//  Created by Anand on 06/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class DriverNetworkModel: ApiNetwork {

    func performDriverSignIn(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "driver/signin/", postCompleted: handler)
    }
    
    func getOrder(handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : Error?) -> Void) {
        get("driver/orders/", completed: handler)
    }
    
    func updateOrderStatus(param : [String: AnyObject], orderId: String, handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        put(param, path: "driver/orders/\(orderId)/", postCompleted: handler)
    }
}
