//
//  order.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

enum orderStatus : String {
    case OrderPlaced = "order_placed"
    case OrderPickup = "pickup"
    case DropOff = "drop_off"
    case Cleaning = "cleaning"
    case Delivery = "delivered"
    case Cancelled = "cancelled"
    case Completed = "completed"

    static let allValues = [OrderPlaced, OrderPickup, DropOff, Cleaning, Delivery, Cancelled,Completed]
}

enum driverStatus : String {
    case None = ""
    case GetDirection = "driver_got_directions"
    case PickupAssigned = "pickup_assigned_to_driver"
    case LetThemKnow = "driver_clicked_let_them_know_you_are_here"
    case OrderPicked = "driver_picked_up_order"
    case OrderNotPicked = "driver_not_able_to_pickup"
    case DropOffAssigned = "drop_off_assigned_to_driver"
    case OrderNotDropped = "driver_not_able_to_dropoff"
    case OrderDropped = "driver_dropped_off_order"
    
    static let allValues = [None,GetDirection,PickupAssigned,DropOffAssigned,LetThemKnow, OrderPicked,OrderNotPicked,OrderNotDropped,OrderDropped]
}

class order: NSObject {

    var uid: String?
    var userid: String?
    var status: String?
    var service: String?
    var serviceNotes: String?
    var pickupDriverId : String?
    var cardInfo : Card?
    var pickupLocation: UserAddress?
    var pickupDate: String?
    var pDate: Date?

    var pickupTime: String?
    var pickupDriverInst: String?
    var dropOffLocation: UserAddress?
    var dropOffDate: String?
    var dDate: Date?
    
    var dropOffTime: String?
    var dropOffDriverInst: String?
    var dropOffDriverId : String?
    
    var pickupDriverStatus : driverStatus = .None
    var dropOffDriverStatus : driverStatus = .None
    
    var pickupDriverNotes : String?
    var dropOffDriverNotes :  String?
    
    var rescheduleDropOff : String?
    var reschedulePickup :  String?
    
    var pickupfailed : Int = 0
    var dropoff_failed : Int = 0
    
    var rating : Int = -1
    var userReview : String?
    
    var washSetting: String?
    var promo : String?
    var isPaymentMade : Bool = false
    
    // driver_clicked_let_them_know_you_are_here
    //drop_off_assigned_to_driver
    
    var tipAmount: Double?
    var orderCost: Double?
    var totalAmount : Double?
    var discount : Double?
        
    var items: [Item] = []
    
    var ordStatus : orderStatus = .OrderPlaced
    
    init(with object : [String: AnyObject]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
       
        if let ouid = object["id"] as? Int {
            uid = "\(ouid)"
        }
        
        if let nick = object["user_id"] as? String {
            userid = nick
        }
                
        if let statu = object["status"] as? String {
            status = statu
            ordStatus = orderStatus(rawValue: statu) ?? .OrderPlaced
        }
        
        if let promoCode = object["promo_code"] as? String {
            promo = promoCode
        }
        
        if let servic = object["service"] as? String {
            service = servic
        }
        
        if let wash_settings = object["wash_settings"] as? String {
            washSetting = wash_settings
        }
        
        if let service_notes = object["service_notes"] as? String {
            serviceNotes = service_notes.decodeEmoji
        }
        
        if let user_review = object["user_review"] as? String {
            userReview = user_review.decodeEmoji
        }
        
        if let user_rating = object["user_rating"] as? Int {
            rating = user_rating
        }
        
        if let cardIn = object["card"] as? [String : AnyObject] {
            let cardObj = Card(with: cardIn)
            cardInfo = cardObj
        }
        
        if let pickup_location = object["pickup_location"] as? [String : AnyObject] {
            let address = UserAddress(with: pickup_location)
            pickupLocation = address
        }
        if let pickup_date = object["pickup_date"] as? String {
            pickupDate = pickup_date
            pDate = dateFormatter.date(from: pickup_date)
        }
        
        if let pickup_time = object["pickup_time"] as? String {
            pickupTime = pickup_time.lowercased().replacingOccurrences(of: "_to_", with: " - ", options: .literal, range: nil)
        }
        
        if let pickup_driver_instructions = object["pickup_driver_instructions"] as? String {
            pickupDriverInst = pickup_driver_instructions.decodeEmoji
        }
        
        if let drop_off_failed = object["drop_off_failed"] as? Int {
            dropoff_failed = drop_off_failed
        }
        
        if let pickup_failed = object["pickup_failed"] as? Int {
            pickupfailed = pickup_failed
        }
        
        if let drop_off_location = object["drop_off_location"] as? [String: AnyObject] {
            let address = UserAddress(with: drop_off_location)
            dropOffLocation = address
        }
        
        if let drop_off_date = object["drop_off_date"] as? String {
            dropOffDate = drop_off_date
            dDate = dateFormatter.date(from: drop_off_date)

        }
        
        if let drop_off_time = object["drop_off_time"] as? String {
            dropOffTime = drop_off_time.lowercased().replacingOccurrences(of: "_to_", with: " - ", options: .literal, range: nil)
        }
        
        if let drop_off_driver_instructions = object["drop_off_driver_instructions"] as? String {
            dropOffDriverInst = drop_off_driver_instructions.decodeEmoji
        }
        
        if let drop_off_driver = object["drop_off_driver"] as? String {
            dropOffDriverId = drop_off_driver
        }
        
        if let notes_by_drop_off_driver = object["notes_by_drop_off_driver"] as? String {
            dropOffDriverNotes = notes_by_drop_off_driver.decodeEmoji
        }
        
        if let drop_off_driver_status = object["drop_off_driver_status"] as? String {
            dropOffDriverStatus = driverStatus(rawValue: drop_off_driver_status) ?? .None
        }
        
        if let pickup_driver = object["pickup_driver"] as? String {
            pickupDriverId = pickup_driver
        }
        
        if let notes_by_pickup_driver = object["notes_by_pickup_driver"] as? String {
            pickupDriverNotes = notes_by_pickup_driver.decodeEmoji
        }
        
        if let pickup_driver_status = object["pickup_driver_status"] as? String {
            pickupDriverStatus =  driverStatus(rawValue: pickup_driver_status) ?? .None
        }
        
        if let reschedule_drop_off = object["reschedule_drop_off"] as? Int {
            rescheduleDropOff = "\(reschedule_drop_off)"
        }
        
        if let reschedule_pickup = object["reschedule_pickup"] as? Int {
            reschedulePickup = "\(reschedule_pickup)"
        }
        
        if let tip_amount = object["tip_amount"] as? Double {
            tipAmount = tip_amount
        }
        
        if let amount = object["amount"] as? Double {
            orderCost = amount
        }
        
        if let total = object["total"] as? Double {
            totalAmount = total
        }
        
        if let disCnt = object["discount"] as? Double {
            discount = disCnt
        }
        
        if let ispayment = object["is_payment_made"] as? Bool {
           isPaymentMade = ispayment
        }
        
        if let itms = object["items"] as? [[String : AnyObject]] {
            
            for itm in itms {
                let obj = Item(with: itm)
                self.items.append(obj)
            }
        }
        
    }
}
