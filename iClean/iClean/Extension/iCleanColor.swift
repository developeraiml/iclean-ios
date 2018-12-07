//
//  iCleanColor.swift
//  iClean
//
//  Created by Anand on 17/09/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     Creates a UIColor by dividing the given RGB values by 255 and using an alpha of 1.
     */
    static func makeSolidColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor
    {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
    static var darkGreen: UIColor
    {
        return makeSolidColor(red:70, green: 120, blue: 37)
    }
}

