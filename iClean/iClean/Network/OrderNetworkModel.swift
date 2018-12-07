//
//  OrderNetworkModel.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import Foundation

class OrderNetworkModel: ApiNetwork {

    func fetchOrderHistory(offset:String, handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        get("order/?limit=10&offset=\(offset)", completed: handler)
    }
    
    func palceOrder(_ param: [String: AnyObject],_ handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        post(param, path: "order/", postCompleted: handler)
    }
    
    func deleteOrder(orderId: String, handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        delete("order/\(orderId)/", completed: handler)
    }
    
    func retreiveOrder(orderId: String, handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        get("order/\(orderId)/", completed: handler)
    }
    
    
    func updateOrder(_ param: [String: AnyObject],_ orderId : String, _ handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        put(param, path: "order/\(orderId)/", postCompleted: handler)
    }
    
}
