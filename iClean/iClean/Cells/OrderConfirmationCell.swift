//
//  OrderConfirmationCell.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderConfirmationCell: UITableViewCell {

    @IBOutlet weak var washNotes: UILabel!
    @IBOutlet weak var washType: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
