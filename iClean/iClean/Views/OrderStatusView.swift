//
//  OrderStatusView.swift
//  iClean
//
//  Created by Anand on 04/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderStatusView: UIView {

    @IBOutlet weak var progressStick: UIImageView!
    
    @IBOutlet weak var circle1: ICView!
    @IBOutlet weak var circle2: ICView!
    @IBOutlet weak var circle3: ICView!
    @IBOutlet weak var circle4: ICView!
    
    func updateOrderStatus(status : orderStatus) {
        
        circle1.backgroundColor = UIColor.darkGray
        circle2.backgroundColor = UIColor.darkGray
        circle3.backgroundColor = UIColor.darkGray
        circle4.backgroundColor = UIColor.darkGray
        
        var frame = progressStick.frame
        
        switch status {
        case .OrderPlaced:
            circle1.backgroundColor = UIColor.white
            frame.size.width = circle1.frame.origin.x + (circle1.frame.size.width/2)
        case .OrderPickup:
            circle1.backgroundColor = UIColor.white
            circle2.backgroundColor = UIColor.white
            frame.size.width = circle2.frame.origin.x + (circle2.frame.size.width/2)

        case .Cleaning:
            circle1.backgroundColor = UIColor.white
            circle2.backgroundColor = UIColor.white
            circle3.backgroundColor = UIColor.white
            frame.size.width = circle3.frame.origin.x + (circle3.frame.size.width/2)

        default:
            circle1.backgroundColor = UIColor.white
            circle2.backgroundColor = UIColor.white
            circle3.backgroundColor = UIColor.white
            circle4.backgroundColor = UIColor.white
            frame.size.width = circle4.frame.origin.x + (circle4.frame.size.width/2)

        }
        
        frame.size.width -= 10
        
        UIView.animate(withDuration: 0.4) {
            self.progressStick.frame = frame
        }

    }

}
