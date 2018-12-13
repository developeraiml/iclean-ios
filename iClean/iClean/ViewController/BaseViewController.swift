//
//  BaseViewController.swift
//  iClean
//
//  Created by Anand on 19/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var keyboardHandler : ((_ shown: Bool)-> Void)?
    
    var isViewPresented : Bool = false

    fileprivate var alertPopView: AlertPopViewViewController?
    
    fileprivate var alert : UIAlertController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func addKeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        keyboardHandler?(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        print("keyboardWillHide")
        keyboardHandler?(false)

    }
    
    func presentErrorAlert(innerData : [String: AnyObject]){
        
        if let err = innerData["errors"] as? [AnyObject] {
            presentAlert(title: nil, message: err.description )
        }
    }
    
    func presentAlert(title: String?, message : String) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            
            let alert = UIAlertController(title: title ?? "iClean", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentAlert(title: String?, message : String, completion: ((Bool)->Void)?) {
        
        let alert = UIAlertController(title: title ?? "iClean", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
            completion?(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlertOKCancel(title: String?, message : String, completion: ((Bool)->Void)?) {
        
        let alert = UIAlertController(title: title ?? "iClean", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            completion?(false)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            completion?(true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func navigateBack(_ sender: Any) {
        
        if isViewPresented == true {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)

        }
    }
    
    
    func showPopViewWithText(handler : ((_ shown: Bool)-> Void)?) {
        
        alertPopView = nil
        
        if alertPopView == nil {
            alertPopView = storyboard?.instantiateViewController(withIdentifier: "AlertPopViewVCNew") as? AlertPopViewViewController
            
            alertPopView?.willMove(toParent: self)
            self.view.addSubview(alertPopView!.view)
            self.addChild(alertPopView!)
            alertPopView!.didMove(toParent: self)
            
            if let handler = handler {
                alertPopView?.animationHandler = handler
            }
            
        }
    }

    
    func showPopView(popupType : AlertPopType, handler : ((_ shown: Bool)-> Void)?) {
        
        alertPopView = nil
        
        if alertPopView == nil {
            alertPopView = storyboard?.instantiateViewController(withIdentifier: "AlertPopViewVC") as? AlertPopViewViewController
            
            alertPopView?.popType = popupType
            alertPopView?.willMove(toParent: self)
            self.view.addSubview(alertPopView!.view)
            self.addChild(alertPopView!)
            alertPopView!.didMove(toParent: self)
            
            if let handler = handler {
                alertPopView?.animationHandler = handler
            }
            
        }
    }
    
    func showCustomPopView(popupType : AlertPopType, title: String?, customBtnTitle: String?, handler : ((_ shown: Bool)-> Void)?) {
        
        alertPopView = nil
        
        if alertPopView == nil {
            
            let stortBoard = UIStoryboard(name: "Login", bundle: Bundle.main)
            alertPopView = stortBoard.instantiateViewController(withIdentifier: "AlertPopViewVC") as? AlertPopViewViewController
            
            alertPopView?.popType = popupType
            alertPopView?.customMessage = title
            alertPopView?.customBtnName = customBtnTitle
            alertPopView?.willMove(toParent: self)
            self.view.addSubview(alertPopView!.view)
            self.addChild(alertPopView!)
            alertPopView!.didMove(toParent: self)
            
            if let handler = handler {
                alertPopView?.animationHandler = handler
            }
            
        }
    }
    
    func showLoadSpinner(message : String?) {
        
        hideLoadSpinner()
        
        let alertVC = UIAlertController(title: nil, message: message ?? "Please wait ...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .gray
        loadingIndicator.startAnimating();
        
        alertVC.view.addSubview(loadingIndicator)
        
        self.alert = alertVC
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func hideLoadSpinner() {
        
        if self.alert != nil {
            self.alert?.dismiss(animated: false, completion: nil)
            self.alert = nil
        }
    }

}
