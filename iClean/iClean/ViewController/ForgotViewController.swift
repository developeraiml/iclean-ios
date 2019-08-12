//
//  ForgotViewController.swift
//  iClean
//
//  Created by Anand on 22/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class ForgotViewController: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func removeViewFromParent() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    @IBAction func sendAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        guard let email = emailTextField.text?.trimWhiteSpace(),  !email.isEmpty, email.isValidEmail() else {
            //Throw error
            presentAlert(title: nil, message: "please add valid Email")
            return
        }
        
        let api = LoginNetworkModel()
        
        showLoadSpinner(message: "Sending ...")

        api.performForgot(param: ["email": email as AnyObject]) { [weak self](success, response, error) in
            
            debugPrint(response,success)
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                if success {
                    let message = response?["message"] as? String
                   // strongSelf.presentAlert(title: nil, message: message ?? "Api Error")
                    strongSelf.presentAlert(title: nil, message: message ?? "Api Error", completion: { (status) in
                        strongSelf.removeViewFromParent()
                    })
                    
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")

                }
            })
          
        }
        
    }
    @IBAction func cancelAction(_ sender: Any) {
        
        removeViewFromParent()
    }
}
