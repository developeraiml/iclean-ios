//
//  WashSettingNetworkModel.swift
//  iClean
//
//  Created by Anand on 25/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class WashSettingNetworkModel: ApiNetwork {
    
    func addWashSettings(param : [String: AnyObject], handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        put(param, path: "user/wash-settings/", postCompleted: handler)
    }

    func fetchWashSettings(handler : @escaping (_ succeeded: Bool, _ result: [String: AnyObject]?, _ error : NSError?) -> Void) {
        
        get("user/wash-settings/", completed: handler)
    }

}
