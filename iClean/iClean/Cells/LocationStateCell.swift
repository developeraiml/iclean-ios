//
//  LocationStateCell.swift
//  iClean
//
//  Created by Anand on 16/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class LocationStateCell: UITableViewCell {

    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
