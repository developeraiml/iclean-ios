//
//  CustomerPreviewCell.swift
//  iClean
//
//  Created by Anand on 07/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class CustomerPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var pickUpTime: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var specialInstructionLbl: UILabel!
    
    @IBOutlet weak var specialNotes: UITextView!
    
    @IBOutlet weak var letThemKnowBtn: UIButton!
}
