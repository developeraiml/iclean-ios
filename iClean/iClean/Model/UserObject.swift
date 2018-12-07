//
//  UserObject.swift
//  iClean
//
//  Created by Anand on 21/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class UserObject: NSObject {

    var name: String?
    var placeholder: String?
    var keyboardType: UIKeyboardType = .asciiCapable
    var returnType: UIReturnKeyType  = .next
    var textFormat: String?
    var tag: Int = 0
    var captionPlaceholder: String?
    var keyName: String?
    var errorMessage: String?
    
    var isEditable : Bool = true
    
    var isValid: Bool = false
    
    override init() {
        super.init()
    }
}
