//
//  GoogleManager.swift
//  CricPool_lite
//
//  Created by Anand kumar on 30/04/17.
//  Copyright © 2017 Anand kumar. All rights reserved.
//

import UIKit


typealias AuthStateAuthorizationCallback = ((_ authState: OIDAuthState?, _ error : Error?) -> ())
typealias RefreshTokenCallback = ((_ response: OIDTokenResponse?, _ error : Error?) -> ())


let kClientID = "395310168549-mbu7rmrql66sdapcq57lpfr2ep9reuf0.apps.googleusercontent.com"
//"616129604011-optr394fmdguvuc5dgstld1ij4lg5g5p.apps.googleusercontent.com"

let kRedirectURI = "com.googleusercontent.apps.395310168549-mbu7rmrql66sdapcq57lpfr2ep9reuf0:/oauth2redirect/example-provider"

//395310168549-mbu7rmrql66sdapcq57lpfr2ep9reuf0.apps.googleusercontent.com

let kAppAuthExampleAuthStateKey = "authState"

let KOAUTHACCESSTOKEN = "access_token"
let KOAUTHREFRESHTOKEN = "refresh_token"
let KOAUTHEXPIREDATE = "expires_in"

//https://www.youtube.com/live_dashboard

class GoogleManager: NSObject {

    static let sharedInstance = GoogleManager()
    
    let authorizationEndpoint : URL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
    let tokenEndpoint : URL = URL(string: "https://www.googleapis.com/oauth2/v4/token")!

    fileprivate var configuration : OIDServiceConfiguration?
    fileprivate var accessToken : String?
    fileprivate var refreshToken : String?
    fileprivate var expireDate : Date?
    
    private override init() {
        configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint, tokenEndpoint: tokenEndpoint)
        
        let userDefault = UserDefaults.standard
        
        if (userDefault.object(forKey: KOAUTHACCESSTOKEN) != nil) {
            accessToken = userDefault.object(forKey: KOAUTHACCESSTOKEN) as? String
        }
        
        if (userDefault.object(forKey: KOAUTHREFRESHTOKEN) != nil) {
            refreshToken = userDefault.object(forKey: KOAUTHREFRESHTOKEN) as? String
        }
        
        if (userDefault.object(forKey: KOAUTHEXPIREDATE) != nil) {
            expireDate = userDefault.object(forKey: KOAUTHEXPIREDATE) as? Date
        }
    }
    
    
    func googleAuthorization(viewcontroller : UIViewController, withCallBack callback: @escaping AuthStateAuthorizationCallback){
        
        let scope = ["https://www.googleapis.com/auth/youtube","https://www.googleapis.com/auth/youtube.force-ssl","https://www.googleapis.com/auth/userinfo.profile","https://www.googleapis.com/auth/userinfo.email","https://www.googleapis.com/auth/youtubepartner", "https://www.googleapis.com/auth/youtubepartner-channel-audit"]
        
        let request : OIDAuthorizationRequest = OIDAuthorizationRequest(configuration: configuration!, clientId: kClientID, scopes: scope, redirectURL: URL(string: kRedirectURI)!, responseType: OIDResponseTypeCode, additionalParameters: nil)
        
        
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: viewcontroller, callback: { (authState : OIDAuthState?, error : Error?) in
            
            let userDefault = UserDefaults.standard
            
            let expDate = Date(timeInterval: 3600, since: Date())
            
            self.accessToken = authState?.lastTokenResponse?.accessToken
            self.refreshToken = authState?.lastTokenResponse?.refreshToken
            self.expireDate = expDate
            
            
            userDefault.set(authState?.lastTokenResponse?.accessToken, forKey: KOAUTHACCESSTOKEN)
            userDefault.set(authState?.lastTokenResponse?.refreshToken, forKey: KOAUTHREFRESHTOKEN)
            userDefault.set(expDate, forKey: KOAUTHEXPIREDATE)

            userDefault.synchronize()
    
            callback(authState, error)
            
        })
        
    }
    
    func getAccessToken() -> String? {
        return accessToken
    }
    
    func getRefreshToken() -> String? {
        return refreshToken
    }
    
    func isTokenExpired() -> Bool {
        
        var expired : Bool = true
        
        if expireDate?.compare(Date()) == .orderedDescending {
            expired = false
        }
        
        return expired
    }
    
    
    func refreshAccessToken(accessToken : String, refrehToken : String?, callback: @escaping RefreshTokenCallback) {
        
        var refreshTkn = refreshToken
        
        if refrehToken != nil {
            refreshTkn = refrehToken
        }
        
        let tokenRefreshRequest : OIDTokenRequest = OIDTokenRequest(configuration: configuration!, grantType: "refresh_token", authorizationCode: nil, redirectURL: URL(string: kRedirectURI)!, clientID: kClientID, clientSecret: nil, scope: nil , refreshToken: refreshTkn, codeVerifier: nil, additionalParameters: nil)
        
        OIDAuthorizationService.perform(tokenRefreshRequest) { (response : OIDTokenResponse?, error : Error?) in
            
           // debugPrint(error)
            if error == nil {
                
                
                let userDefault = UserDefaults.standard
                
                let expDate = Date(timeInterval: 3600, since: Date())
                
                self.accessToken = response?.accessToken
               // self.refreshToken = response?.refreshToken
                self.expireDate = expDate
                
                userDefault.set(response?.accessToken, forKey: KOAUTHACCESSTOKEN)
             //   userDefault.set(response?.refreshToken, forKey: KOAUTHREFRESHTOKEN)
                userDefault.set(expDate, forKey: KOAUTHEXPIREDATE)
                
                userDefault.synchronize()

                
            }
            
            callback(response, error)
        }
        
        
    }
    
}
