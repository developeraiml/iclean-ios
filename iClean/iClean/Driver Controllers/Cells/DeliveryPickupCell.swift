//
//  DeliveryPickupCell.swift
//  iClean
//
//  Created by Anand on 07/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class DeliveryPickupCell: UICollectionViewCell {
    
    @IBOutlet weak var customerName: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var specialInstructionLbl: UILabel!
    
    @IBOutlet weak var specialNotes: UITextView!
    
    @IBOutlet weak var makeCallBtn: ICButton!
    
    @IBOutlet weak var leaveAtDoorman: UILabel!
    @IBOutlet weak var bottmTextLbl: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
}
