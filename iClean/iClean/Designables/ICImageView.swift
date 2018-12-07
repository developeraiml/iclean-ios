
//  Created by Anand on 23/08/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

@IBDesignable

class ICImageView: UIImageView {

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
    
    @IBInspectable var bgColor: UIColor = .clear {
        didSet {
            backgroundColor = bgColor
        }
    }

}
