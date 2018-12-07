//
//  newOrder.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class newOrder: NSObject {

    var promoCode: String?
    var promoPlaceHolder : String? = "Enter Promo Code"
    var washSetting : wash?
    var pickupList : [pickUp] = []
    
    override init() {
        super.init()
        prepareNewOrderInstance()
    }
    
    fileprivate func prepareNewOrderInstance() {
        
    washSetting = wash()
    washSetting?.washKeyname = "service"
    washSetting?.washNoteKeyName = "service_notes"
    
        
    let pickOff = pickUp()
        pickOff.pickUpType = "PICK UP"
        pickOff.instructionKeyName = "pickup_driver_instructions"
        pickOff.selectedDateKeyName = "pickup_date"
        pickOff.selectedTimeKeyName = "pickup_time"
        pickOff.selectedAddressKeyName = "pickup_location"
        
    
        let dropOff = pickUp()
        dropOff.pickUpType = "DROP OFF"
        dropOff.instructionKeyName = "drop_off_driver_instructions"
        dropOff.selectedDateKeyName = "drop_off_date"
        dropOff.selectedTimeKeyName = "drop_off_time"
        dropOff.selectedAddressKeyName = "drop_off_location"
        
        pickupList = [pickOff,dropOff]
    }
}
