//
//  CustomSettingCell.swift
//  iClean
//
//  Created by Anand on 18/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class CustomSettingCell: UITableViewCell {
    
    fileprivate let greenColor = UIColor(red: 76.0/255.0, green: 222.0/255.0, blue: 168.0/255.0, alpha: 1.0)
    fileprivate let grayColor = UIColor(red: 114.0/255.0, green: 114.0/255.0, blue: 114.0/255.0, alpha: 1.0)


    @IBOutlet weak var customTextView: CustomTextView!
    @IBOutlet weak var stackView: ICStackView!
    
    var selectHandler : ((_ keyName: String)->Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func stackInnerButtonAction(_ sender: UIButton) {
        
        guard let views = (stackView.arrangedSubviews as? [StackInfoView]) else {
            return
        }
        
        for view in views {
            
            view.button.backgroundColor = UIColor.clear
            view.tickImage.image = UIImage(named: "tick")
            view.label.textColor = grayColor
            
            if view.button === sender {
                view.button.backgroundColor = greenColor
                view.tickImage.image = UIImage(named: "tickActive")
                view.label.textColor = UIColor.white
                
                if let handler = selectHandler {
                    handler(view.button.titleLabel?.text ?? "")
                }
            }
            
        }
        
    }
    
    func updateButtonStatus( keyList : [String]) {
        
        guard let views = (stackView.arrangedSubviews as? [StackInfoView]) else {
            return
        }
        
        for view in views {
            
            view.button.backgroundColor = UIColor.clear
            view.tickImage.image = UIImage(named: "tick")
            view.label.textColor = grayColor
            
            for key in keyList {
                if view.button.titleLabel?.text == key {
                    view.button.backgroundColor = greenColor
                    view.tickImage.image = UIImage(named: "tickActive")
                    view.label.textColor = UIColor.white
                    
                    if let handler = selectHandler {
                        handler(view.button.titleLabel?.text ?? "")
                    }
                }
            }
        }
    }
}
