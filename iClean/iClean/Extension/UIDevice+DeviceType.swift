//
//  UIDevice+DeviceType.swift
//  ChefD
//
//  Created by YML on 16/11/16.
//  Copyright © 2016 YML. All rights reserved.
//

import Foundation
import UIKit

// MARK: - To indentify the device 
// Useful to indetify the device and perfrom device specific operations such as layouting
extension UIDevice {
    
    class func indentifierForVendor() -> String
    {
        return ""
    }
    
    var modelType: UIDeviceModelType {
        var type: UIDeviceModelType = .iPhone6or7
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.bounds.size.height {
            case 480.0:
                type = .iPhone4
                
            case 568.0:
                type = .iPhone5
                
            case 667.0:
                type = .iPhone6or7
                
            case 736.0:
                type = .iPhone6or7Plus
                
            default:
                type = .iPhone6or7Plus
            }
        }
        else {
            type = .iPad
        }
        
        return type
    }
}

//String representation of device model
enum UIDeviceModelType: Int {
    case iPhone4 = 1
    case iPhone5
    case iPhone6or7
    case iPhone6or7Plus
 
    case iPad
    
    var stringValue: String {
        switch self {
        case .iPhone4:
            return "iPhone 4(s)"
            
        case .iPhone5:
            return "iPhone 5(s)"
            
        case .iPhone6or7:
            return "iPhone 6s"
            
        case .iPhone6or7Plus:
            return "iPhone 6(s) Plus"
      
        case .iPad:
            return "iPad"
        }
    }
}


