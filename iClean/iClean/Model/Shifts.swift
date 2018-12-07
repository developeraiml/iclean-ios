//
//  Shifts.swift
//  iClean
//
//  Created by Anand on 07/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class Shifts: NSObject {

    var shiftDate : String?
    var list: [driverOrder] = []
    
    init(with object : [AnyObject]) {
        
        for ord in object {
            
            let item = driverOrder(with: ord as! [String: AnyObject])
            self.list.append(item)
        }

    }
}
