//
//  ReviewTipsCell.swift
//  iClean
//
//  Created by Anand on 01/12/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class ReviewTipsCell: UITableViewCell {

    @IBOutlet weak var orderAmount: UILabel!
    @IBOutlet weak var discountAmount: UILabel!
    @IBOutlet weak var tipAmount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
