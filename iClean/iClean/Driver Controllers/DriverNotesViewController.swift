//
//  DriverNotesVC.swift
//  iClean
//
//  Created by Anand on 07/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class DriverNotesViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var placeHolder: UILabel!
    @IBOutlet weak var noteView: UITextView!
    
    var handler : ((_ noteText : String)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        placeHolder.isHidden = false
        if textView.text.count != 0 {
            placeHolder.isHidden = true
        }
    }
    
    @IBAction func OkayAction(_ sender: Any) {
        view.endEditing(true)

        if let handler = handler {
            handler(noteView.text)
        }
     
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        dismissVC()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    fileprivate func dismissVC() {
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
}
