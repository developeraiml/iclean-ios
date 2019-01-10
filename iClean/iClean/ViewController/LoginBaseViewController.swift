//
//  LoginBaseViewController.swift
//  iClean
//
//  Created by Anand on 22/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit
import Social
import StoreKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginBaseViewController: BaseViewController {
    
    var socialHandler: ( (_ param : [String: AnyObject], _ secondParam: [String: AnyObject])-> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func performFaceBookSignInAction() {
        
//        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
//
//            let accountStore = ACAccountStore()
//            let fbAccount = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
//
//            let options = ["ACFacebookAppIdKey": "697374160636228",
//                           "ACFacebookPermissionsKey" : ["email"],
//                           "ACFacebookAudienceKey" : ACFacebookAudienceEveryone] as [String : Any]
//
//            accountStore.requestAccessToAccounts(with: fbAccount, options: options) { (granted : Bool, error : Error?) in
//
//                if granted == true {
//
//                    if let account = accountStore.accounts(with: fbAccount)?.last as? ACAccount {
//                        debugPrint(account.username, account.identifier)
//
//                    }
//
//                }
//            }
//
//        } else {
            signInUsingFacebook()
      //  }
        
    }
    
    
    func performGoogleSignInAction() {
        
        GoogleManager.sharedInstance.googleAuthorization(viewcontroller: self, withCallBack: { (authSate : OIDAuthState?, error : Error?) in
            
            //  debugPrint("access = \(authSate?.lastTokenResponse?.accessToken)")
            // debugPrint("refresh = \(authSate?.lastTokenResponse?.refreshToken)")
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if authSate?.lastTokenResponse?.accessToken != nil {
                    strongSelf.showLoadSpinner(message: "Google Signin ...")
                    strongSelf.getuserInfo()
                } else {
                    strongSelf.hideLoadSpinner()
                    
                    strongSelf.presentAlert(title: nil, message: "Google Sign In was cancelled")
                }
                
            })
            
        })
        
    }
    
    func signInUsingFacebook(){
        
        if FBSDKAccessToken.current() != nil {
            //Fetch User Info
            getFBUserInfo()
            return
        }
        
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile","email"]) { [weak self]( result: FBSDKLoginManagerLoginResult?, error: Error?) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if error == nil && result?.isCancelled == false {
                    strongSelf.getFBUserInfo()
                } else {
                    debugPrint("not granted")
                    strongSelf.presentAlert(title: nil, message: "Facebook SignIn Cancelled")

                }
                
            })
            
        }
    }
    
    func getFBUserInfo() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,about,birthday,email,gender,name,picture"])?.start(completionHandler: { (connection, result, error) in
            
            if let dict = result as? [String: AnyObject] {
                
                let fbId = dict["id"] as? String
                var secondParam: [String: AnyObject ] = [:]
                
                if let name = dict["name"] as? String {
                    secondParam["name"] = name as AnyObject
                }
                
                if let email = dict["email"] as? String {
                    secondParam["email"] = email as AnyObject
                }
                
                let param = ["facebook_id": fbId, "access_token" : FBSDKAccessToken.current()?.tokenString]
                
                if let handler = self.socialHandler {
                    handler(param as [String : AnyObject],secondParam as [String : AnyObject])
                }
            } else {
                
                if let handler = self.socialHandler {
                    handler([:],[:])
                }
            }
         
        })
    }

    fileprivate func getuserInfo() {
        
        if GoogleManager.sharedInstance.isTokenExpired() == true {
            refreshToken()
        } else {
            
            let api = GoogleNetworkModel(urlString: "https://www.googleapis.com/oauth2/v1/userinfo")
            
            api.getGoogleUserInfo { [weak self](success, response, error) in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.hideLoadSpinner()
                
                if let data = response  {
                    
                    if data["error"] != nil {
                        return
                    }
                    
                    let email = data["email"] as? String
                    let fname = data["name"] as? String
                    //let lname = data["family_name"] as? String
                    // let pic = data["picture"] as? String
                    let gid = data["id"] as? String
                    let accessToken = GoogleManager.sharedInstance.getAccessToken()
                    
                    let param = ["google_id": gid, "access_token" : accessToken]
                    let secondParam = ["email": email, "name": fname]
                    
                    if let googleHandler = strongSelf.socialHandler {
                        googleHandler(param as [String : AnyObject], secondParam as [String : AnyObject])
                    }
                }
                
            }
            
        }
    }
    
    fileprivate func refreshToken() {
        
        //debugPrint("access = \(authSate?.lastTokenResponse?.accessToken)")
        // debugPrint("refresh = \(authSate?.lastTokenResponse?.refreshToken)")
        
        GoogleManager.sharedInstance.refreshAccessToken(accessToken: "", refrehToken: nil, callback: { (response : OIDTokenResponse?, error : Error?) in
            
            DispatchQueue.main.async(execute: {
                self.getuserInfo()
            })
            
        })
    }

}
