//
//  CustomTextView.swift
//  iClean
//
//  Created by Anand on 19/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class CustomTextView: ICView {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!

    var selectHandler : ((_ keyName: String, _ tag : Int)->Void)?

    var didBeginEditing : ((Bool)->Void)?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var textViewDesc : String? {
        
        didSet {
            textView.text = textViewDesc
            label.isHidden = false
            if textView.text.count > 0 {
                label.isHidden = true
            }
        }
    }

}

extension CustomTextView: UITextViewDelegate {
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if let handelr = didBeginEditing {
            handelr(true)
        }
        
        return true
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard let text = textView.text else {
            return true
        }
        label.isHidden = true
        if text.count == 0 {
            label.isHidden = false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard let text = textView.text else {
            return
        }
        label.isHidden = true
        if text.count == 0 {
            label.isHidden = false
        }
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if let handler = selectHandler {
            handler(textView.text,self.tag)
        }
    }
}
