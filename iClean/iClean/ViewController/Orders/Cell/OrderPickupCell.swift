//
//  OrderPickupCell.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderPickupCell: UITableViewCell {

    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var pickup: UILabel!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dateBtn: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeBtn: UIButton!
    
    @IBOutlet weak var customTextView: CustomTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
