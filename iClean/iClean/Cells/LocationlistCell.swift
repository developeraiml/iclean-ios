//
//  LocationlistCell.swift
//  iClean
//
//  Created by Anand on 28/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class LocationlistCell: UITableViewCell {

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var address: UILabel!
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
