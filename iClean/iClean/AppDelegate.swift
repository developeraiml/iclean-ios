//
//  AppDelegate.swift
//  iClean
//
//  Created by Anand on 16/09/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import UserNotifications
import Braintree

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currentAuthorizationFlow : OIDAuthorizationFlowSession?
    fileprivate var reachability : Reachability!
    var devicePushNotificationToken : String? = "154398FED52E94B41253C4A5D0BE2C287D41CE75A0C703CDA304BB0EC02BC722"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
         NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didNetworkStatusChange), name: ReachabilityChangedNotification, object: nil)
        
        setupReachability()

        if GoogleManager.sharedInstance.isTokenExpired() == true && GoogleManager.sharedInstance.getAccessToken() != nil{
            refreshToken()
        }
        
        setupPushNotification()
        
        if let _ = UserDefaults.standard.object(forKey: "userId") {
            movetoDashboard()
        }
        else if let _ = UserDefaults.standard.object(forKey: "driverUserId") {
            movetoDriverDashboard()
        }
        
        BTAppSwitch.setReturnURLScheme("com.shaginian.SampleBraintree.payments")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString,deviceToken)
        
        self.devicePushNotificationToken = deviceTokenString
    }

    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
        
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//
//        if self.currentAuthorizationFlow?.resumeAuthorizationFlow(with: url) == true {
//            self.currentAuthorizationFlow = nil;
//            return true;
//        }
//
//        return false
//    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication: String? = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        
        //[url.scheme localizedCaseInsensitiveCompare:@"com.shaginian.SampleBraintree.payments"]
        if let orderType = url.scheme?.contains("com.googleusercontent.apps"), orderType == true {
            if self.currentAuthorizationFlow?.resumeAuthorizationFlow(with: url) == true {
                            self.currentAuthorizationFlow = nil;
                            return true;
                }
            return false
        } else if url.scheme?.localizedCaseInsensitiveCompare("com.shaginian.SampleBraintree.payments") == ComparisonResult.orderedSame {
            BTAppSwitch.handleOpen(url, sourceApplication: sourceApplication)
        }
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: nil)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.application(application, open: url, options: [:])
    }
    
    func setupPushNotification(){
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                
                guard error == nil else {
                    //Display Error.. Handle Error.. etc..
                    return
                }
                
                if granted {
                    //Do stuff here..
                }
                else {
                    //Handle user denying permissions..
                }
                
            }
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            // Fallback on earlier versions
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
    }
    
    fileprivate func refreshToken() {
        
        let accessToken = GoogleManager.sharedInstance.getAccessToken()
        let refreshToken = GoogleManager.sharedInstance.getRefreshToken()
        
        GoogleManager.sharedInstance.refreshAccessToken(accessToken: accessToken!, refrehToken: refreshToken, callback: { (response : OIDTokenResponse?, error : Error?) in
            
            debugPrint(response?.accessToken,response?.refreshToken)
            
        })
    }
    

    //MARK:- Helper
    fileprivate func setupReachability() {
        do {
            reachability = Reachability()
            try reachability?.startNotifier()
            
        } catch {
            debugPrint("Unable to create Reachability instance")
        }
    }
    
    @objc func didNetworkStatusChange(_ notify : Foundation.Notification) {
        _ = isNetworkAvailable()
    }
    
    func  isNetworkAvailable() -> Bool {
        
        var isReachible : Bool = true
        if reachability?.isReachable == false || reachability?.isReachable  == nil {
            isReachible = false
        }
        return isReachible
    }
    
    func switchToDashboard() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeNavigationController") as? UINavigationController
        
        if let loginVC = self.window?.rootViewController?.children.last {
            self.window?.rootViewController = vc
            
            self.window?.rootViewController?.children[0].view.addSubview(loginVC.view)
            
            var frame = UIScreen.main.bounds
            
            UIView.animate(withDuration: 0.4, animations: {
                
                frame.origin.y = frame.size.height
                loginVC.view.frame = frame
            }) { (_) in
                
                loginVC.view.removeFromSuperview()
                loginVC.removeFromParent()
            }
            
        }
    
    }
    
    func switchToDriverDashboard() {
        
        let storyboard = UIStoryboard(name: "Driver", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DriverNavigationController") as? UINavigationController
        
        if let loginVC = self.window?.rootViewController?.children.last {
            self.window?.rootViewController = vc
            
            self.window?.rootViewController?.children[0].view.addSubview(loginVC.view)
            
            var frame = UIScreen.main.bounds
            
            UIView.animate(withDuration: 0.4, animations: {
                
                frame.origin.y = frame.size.height
                loginVC.view.frame = frame
            }) { (_) in
                
                loginVC.view.removeFromSuperview()
                loginVC.removeFromParent()
            }
            
        }
        
    }
    
    func movetoDashboard(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeNavigationController") as? UINavigationController
        self.window?.rootViewController = vc
        
    }
    
    func movetoDriverDashboard(){
        
        let storyboard = UIStoryboard(name: "Driver", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DriverNavigationController") as? UINavigationController
        self.window?.rootViewController = vc
        
    }
    
    func switchToLogin() {
        
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "driverUserId")
        UserDefaults.standard.removeObject(forKey: "isFbGL")
        UserDefaults.standard.synchronize()
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController") as? UINavigationController
        
        if let loginVC = self.window?.rootViewController?.children.last {
           // self.window?.rootViewController = vc
            
            loginVC.present(vc ?? UIViewController(), animated: true) {
                self.window?.rootViewController = vc
            }
            
        }
        
        
    }

}

