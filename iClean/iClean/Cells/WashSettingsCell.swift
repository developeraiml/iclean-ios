//
//  WashSettingsCell.swift
//  iClean
//
//  Created by Anand on 17/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class WashSettingsCell: UITableViewCell {

    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var settingText: UILabel!
    
    @IBOutlet weak var tickBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
