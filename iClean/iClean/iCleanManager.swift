//
//  iCleanManager.swift
//  iClean
//
//  Created by Anand on 21/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class iCleanManager: NSObject {

    static let sharedInstance = iCleanManager()
  
    var brainTreeClientToken : String = ""

     private override init() {
        
    }
    
    func preformGoogleSignIn(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        let deviceType = "1" //iOS
        let deviceUdid =  UIDevice.current.identifierForVendor?.uuidString
        let deviceToken = (UIApplication.shared.delegate as? AppDelegate)!.devicePushNotificationToken
        
        let deviceParam = ["device_type" : deviceType, "device_id" : deviceUdid , "device_token" : deviceToken]
        let signinParam = param.mergedWith(otherDictionary: deviceParam as [String : AnyObject])
        
        let api = LoginNetworkModel()
        api.performGoogleSignIn(param: signinParam, handler: handler)
        
    }
    
    func preformGoogleSignup(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        let deviceType = "1" //iOS
        let deviceUdid =  UIDevice.current.identifierForVendor?.uuidString
        let deviceToken = (UIApplication.shared.delegate as? AppDelegate)!.devicePushNotificationToken
        
        let deviceParam = ["device_type" : deviceType, "device_id" : deviceUdid , "device_token" : deviceToken]
        let signinParam = param.mergedWith(otherDictionary: deviceParam as [String : AnyObject])
        
        let api = LoginNetworkModel()
        api.performGoogleSignup(param: signinParam, handler: handler)
        
    }
    
    
    func preformFBSignIn(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        let deviceType = "1" //iOS
        let deviceUdid =  UIDevice.current.identifierForVendor?.uuidString
        let deviceToken = (UIApplication.shared.delegate as? AppDelegate)!.devicePushNotificationToken
        
        let deviceParam = ["device_type" : deviceType, "device_id" : deviceUdid , "device_token" : deviceToken]
        let signinParam = param.mergedWith(otherDictionary: deviceParam as [String : AnyObject])
        
        let api = LoginNetworkModel()
        api.performFBSignIn(param: signinParam, handler: handler)
        
    }
    
    func preformFBSignup(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        let deviceType = "1" //iOS
        let deviceUdid =  UIDevice.current.identifierForVendor?.uuidString
        let deviceToken = (UIApplication.shared.delegate as? AppDelegate)!.devicePushNotificationToken
        
        let deviceParam = ["device_type" : deviceType, "device_id" : deviceUdid , "device_token" : deviceToken]
        let signinParam = param.mergedWith(otherDictionary: deviceParam as [String : AnyObject])
        
        let api = LoginNetworkModel()
        api.performFBSignup(param: signinParam, handler: handler)
        
    }
    
    func fetchBrainTreeToken() {
        
        let api = BraintreeNetworkModel()
        api.fetchBrainTreeToken { (success, response, error) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                
                guard let strongSelf = self else { return }
                
                if success {
                    
                    if response?["status"] as? Int == 200 {
                        
                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            if let token = innerData["token"] as? String {
                                strongSelf.brainTreeClientToken = token
                            }
                        }
                    }
                }
            })
        }
    }
    
    func isBrainTreeTokenAvailable() -> Bool {
        
        return self.brainTreeClientToken.count == 0 ? false : true
    }
    
}
