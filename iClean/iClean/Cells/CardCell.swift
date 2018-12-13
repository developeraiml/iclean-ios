//
//  CardCell.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var cardType: UILabel!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var nickName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
