//
//  OrderViewController.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderViewController: BaseViewController {

    @IBOutlet weak var tableview: UITableView!
    fileprivate var newOrderObject = newOrder()
    
    fileprivate var originY : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addKeyBoardNotification()
        
        keyboardHandler = { isKeyBoardShown in
            if isKeyBoardShown {
                self.tableview.contentInset = UIEdgeInsets(top: -self.originY, left: 0, bottom: 0, right: 0)
            } else {
                self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }

    }
    

    @IBAction func placeOrderAction(_ sender: Any) {
        
        guard let washSetting = newOrderObject.washSetting, let washname = washSetting.washType else {
            presentAlert(title: nil, message: "Please select the wash type")
            return
        }
        
        guard let order = newOrderObject.pickupList.filter({$0.selectedAddress != nil && $0.selectedDate != nil && $0.selectedTime != nil }) as? [pickUp], order.count == 2 else {
            presentAlert(title: nil, message: "Please provide the valid pickup & drop off information")
            return
        }
        
        guard let instruct = newOrderObject.pickupList.filter({$0.instruction != nil }) as? [pickUp], instruct.count == 2 else {
            presentAlert(title: nil, message: "Please add driver instruction.")
            return
        }
        
        let pick = newOrderObject.pickupList[0] as pickUp
        let dropOff = newOrderObject.pickupList[1] as pickUp
        
        var dict = [washSetting.washKeyname: washname,
                    washSetting.washNoteKeyName: washSetting.washNotes?.encodeEmoji,
                    pick.selectedAddressKeyName: pick.selectedAddress,
                    pick.selectedDateKeyName: pick.selectedDate,
                    pick.selectedTimeKeyName: pick.selectedTime?.lowercased().replacingOccurrences(of: " - ", with: "_to_", options: .literal, range: nil),
                    pick.instructionKeyName: pick.instruction?.encodeEmoji,
                    dropOff.selectedAddressKeyName: dropOff.selectedAddress,
                    dropOff.selectedDateKeyName: dropOff.selectedDate,
                    dropOff.selectedTimeKeyName: dropOff.selectedTime?.lowercased().replacingOccurrences(of: " - ", with: "_to_", options: .literal, range: nil),
                    dropOff.instructionKeyName: dropOff.instruction?.encodeEmoji] as? [String: AnyObject]
        
        if let promo = newOrderObject.promoCode {
            dict?["promo_code"] = promo as AnyObject
        }
        
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "OrderConfirmationVC") as? OrderConfirmationVC
        
        vc?.param = dict
        vc?.orderObject = newOrderObject
        
        self.navigationController?.pushViewController(vc!, animated: true)
                    
    }
    

}


extension OrderViewController: UITextViewDelegate {
    
    @objc func doneAction() {
        resetTableViewScroll()
    }
    
    fileprivate func resetTableViewScroll() {
        
        self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.endEditing(true)
    }
}

extension OrderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 1 ? 2 : 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.section == 0 ? 200 : indexPath.section == 1 ? 300 : 94
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableview.dequeueReusableCell(withIdentifier: "OrderSettingCell") as? CustomSettingCell
            
            cell?.selectHandler = { [weak self] selectedKey in
                
                guard  let strongSelf = self else {
                    return
                }
                
                strongSelf.newOrderObject.washSetting?.washType = selectedKey
                debugPrint(selectedKey)
            }
            
            if cell?.customTextView != nil {
                
                if let notes = newOrderObject.washSetting?.washNotes, notes.count != 0  {
                    cell?.customTextView.textViewDesc = notes
                }
                
                if cell?.customTextView.textView.inputAccessoryView == nil {
                    
                    let bar = UIToolbar()
                    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
                    bar.items = [flexBarButton,done]
                    bar.sizeToFit()
                    cell?.customTextView.textView.inputAccessoryView = bar
                    
                    
                    cell?.customTextView.selectHandler = { text, tag in
                        self.newOrderObject.washSetting?.washNotes = text
                    }
                    
                    cell?.customTextView.didBeginEditing = { status in
                        self.originY = cell?.frame.origin.y ?? 0.0
                    }
                    
                }
            }
            
            if let washName = newOrderObject.washSetting?.washType {
                
                cell?.updateButtonStatus(keyList: [washName])
            }
            
            
            return cell!
        } else if indexPath.section == 1 {
            let cell = tableview.dequeueReusableCell(withIdentifier: "OrderPickupCell") as? OrderPickupCell
            
            let pickObj = newOrderObject.pickupList[indexPath.row]
            
            cell?.pickup.text = pickObj.pickUpType
            
            cell?.locationBtn.tag = indexPath.row
            cell?.dateBtn.tag = indexPath.row
            cell?.timeBtn.tag = indexPath.row
            
            cell?.dateBtn.addTarget(self, action: #selector(showDateUi), for: .touchUpInside)
            cell?.timeBtn.addTarget(self, action: #selector(showTimeUi), for: .touchUpInside)
            cell?.locationBtn.addTarget(self, action: #selector(showLocationUi), for: .touchUpInside)
            
            cell?.locationName.text = pickObj.addressPlaceHolder
            cell?.dateLabel.text = pickObj.datePlaceHolder
            cell?.timeLabel.text = pickObj.timePlaceHolder


            if let nickNname = pickObj.selectedAddress {
                cell?.locationName.text = nickNname
            }
            
            if let dateName = pickObj.selectedDate {
                cell?.dateLabel.text = dateName
            }
            
            if let timeName = pickObj.selectedTime {
                cell?.timeLabel.text = timeName
            }
            
            
            if cell?.customTextView != nil {
                
                cell?.customTextView.tag = indexPath.row
                cell?.customTextView.textViewDesc = ""
                if let notes = newOrderObject.pickupList[indexPath.row].instruction, notes.count != 0  {
                    cell?.customTextView.textViewDesc = notes
                }
                
                if cell?.customTextView.textView.inputAccessoryView == nil {
                    
                    let bar = UIToolbar()
                    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
                    bar.items = [flexBarButton,done]
                    bar.sizeToFit()
                    cell?.customTextView.textView.inputAccessoryView = bar
                    cell?.customTextView.selectHandler = { text, tag in
                        self.newOrderObject.pickupList[tag].instruction = text
                    }
                    
                    cell?.customTextView.didBeginEditing = { status in
                        
                        self.originY = cell?.frame.origin.y ?? 0.0
                       // debugPrint(cell?.frame.origin.y)
                    }
                    
                }
            }
            
            return cell!
        } else {
            let cell = tableview.dequeueReusableCell(withIdentifier: "OrderPromoCell") as? OrderPromoCell
            
            cell?.didBeginEditing = { status in
                 self.originY = cell?.frame.origin.y ?? 0.0
            }
            
            cell?.promoCode.text = self.newOrderObject.promoCode
            
            cell?.didEndEditing = { text in
                self.newOrderObject.promoCode = text
            }
            
            cell?.didBeginEditing = { status in
                self.originY = ((cell?.frame.origin.y ?? 1)/1.2)
            }
            
             if cell?.promoCode.inputAccessoryView == nil {
                
                let bar = UIToolbar()
                let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
                bar.items = [flexBarButton,done]
                bar.sizeToFit()
                cell?.promoCode.inputAccessoryView = bar
            }
            
           // cell?.alpha = 0.5
            //cell?.isUserInteractionEnabled = false
            return cell!
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }

    
}

extension OrderViewController {
    
    @objc func showLocationUi(sender : UIButton) {
        
        self.view.endEditing(true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "LocationListViewController") as? LocationListViewController
        
        vc?.addressSelectHandler = { [weak self] address in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.newOrderObject.pickupList[sender.tag].address = address
                strongSelf.newOrderObject.pickupList[sender.tag].selectedAddress = address.nickname

                strongSelf.tableview.reloadData()
                
                strongSelf.navigationController?.popViewController(animated: true)
            })
        }
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func showDateUi(sender : UIButton) {
        
        self.view.endEditing(true)

        let vc = storyboard?.instantiateViewController(withIdentifier: "PickerViewController") as? PickerViewController
        
        vc?.type = .datePicker
        vc?.selectedDate = newOrderObject.pickupList[sender.tag].sDate
        
        vc?.willMove(toParent: self)
        self.view.addSubview(vc!.view)
        self.addChild(vc!)
        vc!.didMove(toParent: self)
        
        vc?.selectHandler = { [weak self] dateString, sdDate in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if dateString.count != 0 {
                    strongSelf.newOrderObject.pickupList[sender.tag].selectedDate = dateString
                    strongSelf.newOrderObject.pickupList[sender.tag].sDate = sdDate
                    strongSelf.tableview.reloadData()
                }
                
            })
        }
        
    }
    
    @objc func showTimeUi(sender : UIButton) {
        
        self.view.endEditing(true)

        let vc = storyboard?.instantiateViewController(withIdentifier: "PickerViewController") as? PickerViewController
        
        vc?.type = .timePicker
                
        if let timeString = newOrderObject.pickupList[sender.tag].selectedTime {
            vc?.selectedTime = timeString
        }
        
        vc?.willMove(toParent: self)
        self.view.addSubview(vc!.view)
        self.addChild(vc!)
        vc!.didMove(toParent: self)
        
        vc?.selectHandler = { [weak self] timeString, sdDate in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if timeString.count != 0 {
                    strongSelf.newOrderObject.pickupList[sender.tag].selectedTime = timeString
                    strongSelf.tableview.reloadData()
                }
               
                
            })
        }
    }
}
