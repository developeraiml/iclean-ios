//
//  AlertPopViewVC.swift
//  iClean
//
//  Created by Anand on 20/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

public enum AlertPopType: Error {
    case Success
    case RegFailed
    case Sorry
    case Info
    case Complete
    case None
}


class AlertPopViewVC: UIViewController {

    @IBOutlet weak var alertImage: UIImageView!
    @IBOutlet weak var alertText: UILabel!
    @IBOutlet weak var popview: UIView!
    @IBOutlet weak var okayButton: UIButton!
    
    var customMessage: String?
    var customBtnName: String?
    
    var popType: AlertPopType = .None
    
    var animationHandler : ((_ shown: Bool)-> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if customBtnName != nil {
            okayButton.setTitle(customBtnName, for: .normal)
        }
        
        switch popType {
        case .Success:
            showSuccessPopView()
        case .RegFailed:
            showRegSorryPopView()
        case .Sorry:
            showSorryPopView()
        case .Info:
            showInfoPopView()
        case .Complete:
            showOrderComplete()
        default:
            break
        }
        
        performAnimation()
    }
    
    @IBAction func okayAction(_ sender: Any) {
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        animationHandler?(true)

    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
    fileprivate func showSuccessPopView() {
        alertImage.image = UIImage(named: "icnHappy")
        alertImage.isHighlighted = false
        alertText.text = customMessage != nil ? customMessage : "Great news! \nWe service your area! \nLet’s get started."
    }
    
    fileprivate func showRegSorryPopView() {
        alertImage.isHighlighted = true
        alertText.text = customMessage != nil ? customMessage : "Sorry we are not in your neighborhood yet.\nWe’ll email you when we are :)"
    }
    
    fileprivate func showSorryPopView() {
        alertImage.isHighlighted = true
        alertText.text = customMessage != nil ? customMessage : "Sorry we don’t service that area yet!"
    }
    
    fileprivate func showInfoPopView() {
        alertImage.image = UIImage(named: "icnInfoLarge")
        alertImage.isHighlighted = false
        alertText.text = customMessage != nil ? customMessage : "iClean recommended wash is cold wash and medium dry."
    }
    
    fileprivate func showOrderComplete() {
        alertImage.image = UIImage(named: "icnOrderComplete")
        alertImage.isHighlighted = false
        alertText.text = customMessage != nil ? customMessage : "Your Order is Complete!."
    }
    
    func performAnimation() {
        
        popview.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.9, options: .curveEaseInOut, animations: {
            self.popview.transform = CGAffineTransform(scaleX: 1, y: 1)

        }, completion: nil)
    }
}
