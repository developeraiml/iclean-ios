//
//  OrderHistoryCell.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderHistoryCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var starStackView: UIStackView!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var historyDesc: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateRating(rating : Int) {
        
        guard let views = (starStackView.arrangedSubviews as? [UIImageView]) else {
            return
        }
        
        for view in views {
            
            view.isHighlighted = false
            
            if rating >= view.tag {
                view.isHighlighted = true
            }
        }
    }

}
