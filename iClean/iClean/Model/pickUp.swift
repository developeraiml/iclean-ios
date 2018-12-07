//
//  pickUp.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class pickUp: NSObject {
    
    var pickUpType: String?
    
    var selectedAddress : String?
    var selectedAddressKeyName : String?
    var addressPlaceHolder : String? = "Select Location"

    var selectedDate: String?
    var sDate: Date?
    var selectedDateKeyName : String?
    var datePlaceHolder : String? = "Date"

    var selectedTime: String?
    var selectedTimeKeyName: String?
    var timePlaceHolder : String? = "Time"

    
    var instruction: String? = ""
    var instructionKeyName: String?
    
    
    var address: UserAddress?

}
