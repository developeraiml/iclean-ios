//
//  OrderDetailsCell.swift
//  iClean
//
//  Created by Anand on 04/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderDetailsCell: UITableViewCell {

    @IBOutlet weak var pickTypeLbl: UILabel!
    
    @IBOutlet weak var pickDate: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var pickAddress: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
