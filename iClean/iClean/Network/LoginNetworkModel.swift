//
//  LoginNetworkModel.swift
//  iClean
//
//  Created by Anand on 20/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class LoginNetworkModel: ApiNetwork {
    
    func performSignIn(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/signin/", postCompleted: handler)
    }
    
    func performSignup(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/signup/", postCompleted: handler)
    }
    
    func performGoogleSignIn(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/signin/google/", postCompleted: handler)
    }
    
    func performGoogleSignup(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/signup/google/", postCompleted: handler)
    }
    
    
    func performFBSignIn(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/signin/facebook/", postCompleted: handler)
    }
    
    func performFBSignup(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/signup/facebook/", postCompleted: handler)
    }
    
    func performForgot(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        post(param, path: "user/forgot-password/", postCompleted: handler)
    }

}
