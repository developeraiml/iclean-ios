//
//  GoogleNetworkModel.swift
//  iClean
//
//  Created by Anand on 21/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class GoogleNetworkModel: ApiNetwork {
    
    func getGoogleUserInfo(_ handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        let accessToken = GoogleManager.sharedInstance.getAccessToken()
        
        self.get("?alt=json&access_token=" + accessToken!) { (success, result, error) in
            
            handler(success,result,error)
        }

    }

}
