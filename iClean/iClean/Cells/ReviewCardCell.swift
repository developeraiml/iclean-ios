//
//  ReviewCardCell.swift
//  iClean
//
//  Created by Anand on 18/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class ReviewCardCell: UITableViewCell {

    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var cardNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
