//
//  WriteReviewViewController.swift
//  iClean
//
//  Created by Anand on 05/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class WriteReviewViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var reviewNotes: UITextView!
    
    var orderDetails: order?

    fileprivate var selectedRate: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let bar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        bar.items = [flexBarButton,done]
        bar.sizeToFit()
        reviewNotes.inputAccessoryView = bar
    }
    
    @objc func doneAction() {
        resetTableViewScroll()
    }
    
    fileprivate func resetTableViewScroll() {
        view.endEditing(true)
    }
    
    @IBAction func starButtonAction(_ sender: UIButton) {
        
        guard let views = (stackView.arrangedSubviews as? [UIButton]) else {
            return
        }
        
        let index = sender.tag
        selectedRate = index
        
        for button in views {
            
            button.isSelected = false
            
            if button.tag <= index {
                button.isSelected = true
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
   
    func textViewDidChange(_ textView: UITextView) {
        
        guard let text = textView.text else {
            return
        }
        placeHolderLbl.isHidden = true
        if text.count == 0 {
            placeHolderLbl.isHidden = false
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        if selectedRate == 0 || reviewNotes.text.isEmpty {
            
            presentAlertOKCancel(title: nil, message: "Do you want to submit without review notes or rating.") { (status) in
                
                if status {
                    self.callSubmitApi()
                }
            }
            
        } else {
            callSubmitApi()
        }
    }
    
    fileprivate func callSubmitApi() {
        
        let api = OrderNetworkModel()
        
        let notes = (reviewNotes.text ?? "").encodeEmoji
        
        
        let dict = ["user_rating" : "\(selectedRate)",
            "user_review": notes ] as [String : AnyObject]
        
         showLoadSpinner(message: "Saving Review ...")
        api.updateOrder(dict, orderDetails?.uid ?? "0") { (success, response, error) in
            
            //debugPrint(response)
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                
                if success {
                    
                    let message = response?["message"] as? String
                    if response?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                appDel.switchToLogin()
                            }
                        })
                        
                    } else if response?["status"] as? Int == 200 {
                        
                        strongSelf.presentAlert(title: nil, message: "Review added successfully", completion: { (status) in
                            strongSelf.navigationController?.popToRootViewController(animated: true)
                        })
                        
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")

                }
            })
        }
    }
    
}
