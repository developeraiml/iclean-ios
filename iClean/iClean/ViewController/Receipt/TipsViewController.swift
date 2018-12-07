//
//  TipsViewController.swift
//  iClean
//
//  Created by Anand on 04/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class TipsViewController: BaseViewController {

    @IBOutlet weak var tipAmountLbl: UILabel!
    
    fileprivate var tipAmount : String = ""
    fileprivate let numberFormatter = NumberFormatter()

    var totalAmount : Double = 0.0
    
    var tipAddHandler : ((_ tipAmt: String)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.multiplier = 1
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 2
    }
    

    
    @IBAction func tipPercentAction(_ sender: UIButton) {
        
        tipAmount = ""
        
        let amount = (totalAmount/100) * Double(sender.tag)
        
        self.tipAmountLbl.text = "\(amount)"
        
    }
    
    
    @IBAction func calculatorButtonAction(_ sender: UIButton) {
        
        tipAmount += sender.titleLabel?.text ?? ""
        
        if let range = tipAmount.range(of: ".") {
            let decimal = tipAmount[range.upperBound...]
            
            if decimal.count > 2 {
                tipAmount.removeLast()
            }
        }

        let number = numberFormatter.number(from: tipAmount)
        
        self.tipAmountLbl.text = "\(number?.floatValue ?? 0.0)"
    }
    
    @IBAction func clearbackAction(_ sender: UIButton) {
        
        if tipAmount.count != 0 {
            tipAmount.removeLast()
        }
        
        if tipAmount.suffix(1) == "." {
            tipAmount.removeLast()
        }

        
        let number = numberFormatter.number(from: tipAmount)
        
        self.tipAmountLbl.text = "\(number?.floatValue ?? 0.0)"
    }
    
    @IBAction func dotOperAction(_ sender: UIButton) {
        
        if !tipAmount.contains(".") {
            tipAmount += "."
        }
        let number = numberFormatter.number(from: tipAmount)
        
        self.tipAmountLbl.text = "\(number?.floatValue ?? 0.0)"
    }
    
    @IBAction func addTipAction(_ sender: Any) {
        
        if let handler = tipAddHandler {
            handler(self.tipAmountLbl.text ?? "0.0")
        }
        
        removeViewController()
    }
    
    fileprivate func removeViewController() {
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeViewController()
    }
}
