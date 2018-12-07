
//  Created by Anand on 23/08/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

@IBDesignable

class ICView: UIView {

    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable public var bordrColor: UIColor = .clear {
        didSet {
            self.layer.borderColor = self.bordrColor.cgColor
        }
    }
    
    @IBInspectable public var bordrWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.bordrWidth
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.white {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGFloat = 0 {
        didSet {
            layer.shadowOffset = CGSize(width: 0, height: shadowOffset)
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var bgColor: UIColor = .clear {
        didSet {
            backgroundColor = bgColor
        }
    }
    
}
