//
//  HomeCell.swift
//  iClean
//
//  Created by Anand on 20/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class HomeCell: UITableViewCell {

    @IBOutlet weak var homeText: UILabel!
    @IBOutlet weak var homeImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
