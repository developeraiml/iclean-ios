//
//  OrderUpdateViewController.swift
//  iClean
//
//  Created by Anand on 04/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderUpdateViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableview: UITableView!
    
    var pickObj : order?
    var editPickInfo : Bool = true
    var isRescheduled : Bool = false

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
        
        tableview.tableFooterView = UIView()
    }
    

    @objc fileprivate func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        showLoadSpinner(message: "Updating Order ...")
        
       let api  = OrderNetworkModel()
        
        api.updateOrder(getParams() ?? [:], pickObj?.uid ?? "") { (success, response, error) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                
                if success {
                    
                    let message = response?["message"] as? String
                    
                    if response?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                appDel.switchToLogin()
                            }
                        })
                        
                    } else if response?["status"] as? Int == 200 {
                        
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error", completion: { (status) in
                            
                            for controller in self?.navigationController?.children ?? [] {
                                
                                if controller is OrderStatusViewController {
                                    
                                    strongSelf.navigationController?.popToViewController(controller, animated: true)

                                    return
                                }
                            }
                                                       
                        })
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")

                    }
                    
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")

                }
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  editPickInfo == true ? 2 : 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  300 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: GeneralConstants.orderUpdatePickupCell) as? OrderPickupCell
        
        cell?.pickup.text = editPickInfo == true ? "PICK UP" : "DROP OFF"
        
        if indexPath.row == 1 {
            cell?.pickup.text =  "DROP OFF"
        }
        
        cell?.locationBtn.tag = indexPath.row
        cell?.dateBtn.tag = indexPath.row
        cell?.timeBtn.tag = indexPath.row
        
        cell?.dateBtn.addTarget(self, action: #selector(showDateUi), for: .touchUpInside)
        cell?.timeBtn.addTarget(self, action: #selector(showTimeUi), for: .touchUpInside)
        cell?.locationBtn.addTarget(self, action: #selector(showLocationUi), for: .touchUpInside)
        
        if editPickInfo {
            
            if indexPath.row == 0 {
                if let address = pickObj?.pickupLocation {
                    cell?.locationName.text = address.nickname
                }
                
                cell?.dateLabel.text = pickObj?.pickupDate
                cell?.timeLabel.text = pickObj?.pickupTime
            } else {
                if let address = pickObj?.dropOffLocation {
                    cell?.locationName.text = address.nickname
                }
                cell?.dateLabel.text = pickObj?.dropOffDate
                cell?.timeLabel.text = pickObj?.dropOffTime
            }
            

        } else {
            
            if let address = pickObj?.dropOffLocation {
                cell?.locationName.text = address.nickname
            }
            cell?.dateLabel.text = pickObj?.dropOffDate
            cell?.timeLabel.text = pickObj?.dropOffTime

        }
        
        
        if cell?.customTextView != nil {
            
            if cell?.customTextView.textView.inputAccessoryView == nil {
                
                let bar = UIToolbar()
                let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyBoard))
                bar.items = [flexBarButton,done]
                bar.sizeToFit()
                cell?.customTextView.textView.inputAccessoryView = bar
                
                if let notes = (editPickInfo ==  true) ? pickObj?.pickupDriverInst : pickObj?.dropOffDriverInst, notes.count != 0  {
                    cell?.customTextView.textViewDesc = notes
                }
                
                cell?.customTextView.selectHandler = { text, tag in
                    
                    if (self.editPickInfo ==  true) {
                        self.pickObj?.pickupDriverInst = text
                    } else {
                        self.pickObj?.dropOffDriverInst = text
                    }
                }
                
                cell?.customTextView.didBeginEditing = { status in
                    self.originY = cell?.frame.origin.y ?? 0.0
                }
                
            }
        }
        
        return cell!
    }
    
}


extension OrderUpdateViewController {
    
    @objc func showLocationUi(sender : UIButton) {
        
        self.view.endEditing(true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.locationListVC) as? LocationListViewController
        
        vc?.addressSelectHandler = { [weak self] address in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if strongSelf.editPickInfo ==  true {
                    if sender.tag == 0 {
                        strongSelf.pickObj?.pickupLocation = address
                    } else {
                        strongSelf.pickObj?.dropOffLocation = address
                    }
                } else {
                    strongSelf.pickObj?.dropOffLocation = address
                }
                
                strongSelf.tableview.reloadData()
                
                strongSelf.navigationController?.popViewController(animated: true)
            })
        }
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func showDateUi(sender : UIButton) {
        
        self.view.endEditing(true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.pickerVC) as? PickerViewController
        
        vc?.type = .datePicker
        
        if editPickInfo ==  true {
            
            if sender.tag == 0 {
               vc?.selectedDate = pickObj?.pDate
            } else {
                vc?.selectedDate = pickObj?.dDate
            }
        } else {
            vc?.selectedDate = pickObj?.dDate
        }
        
        vc?.willMove(toParent: self)
        self.view.addSubview(vc!.view)
        self.addChild(vc!)
        vc!.didMove(toParent: self)
        
        vc?.selectHandler = { [weak self] dateString,timeString,sdDate in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if dateString?.count != 0 {
                    
                    if strongSelf.editPickInfo ==  true {
                        if sender.tag == 0 {
                            strongSelf.pickObj?.pickupDate = dateString
                            strongSelf.pickObj?.pDate = sdDate

                        } else {
                            strongSelf.pickObj?.dropOffDate = dateString
                            strongSelf.pickObj?.dDate = sdDate

                        }
                    } else {
                    }
                    strongSelf.tableview.reloadData()
                }
                
            })
        }
        
    }
    
    @objc func showTimeUi(sender : UIButton) {
        
        self.view.endEditing(true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.pickerVC) as? PickerViewController
        
        vc?.type = .timePicker
        
        if editPickInfo ==  true {
            
            if sender.tag == 0 {
                vc?.selectedTime = pickObj?.pickupTime
                vc?.selectedDate = pickObj?.pDate

            } else {
                vc?.selectedTime = pickObj?.dropOffTime
                vc?.selectedDate = pickObj?.dDate

            }
        } else {
            vc?.selectedTime = pickObj?.dropOffTime
            vc?.selectedDate = pickObj?.dDate

        }
        
        vc?.willMove(toParent: self)
        self.view.addSubview(vc!.view)
        self.addChild(vc!)
        vc!.didMove(toParent: self)
        
        vc?.selectHandler = { [weak self] dateString,timeString, sdDate in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if timeString?.count != 0 {
                    
                    if strongSelf.editPickInfo ==  true {
                        if sender.tag == 0 {
                            strongSelf.pickObj?.pickupTime = timeString
                        } else {
                            strongSelf.pickObj?.dropOffTime = timeString
                        }
                    } else {
                        strongSelf.pickObj?.dropOffTime = timeString
                    }
                    strongSelf.tableview.reloadData()
                }
                
                
            })
        }
    }
}


extension OrderUpdateViewController {
    
    
    func getParams () -> [String: AnyObject]? {
        
        var dict = ["pickup_location": pickObj?.pickupLocation?.nickname,
                    "pickup_date": pickObj?.pickupDate,
                    "pickup_time": pickObj?.pickupTime?.lowercased().replacingOccurrences(of: " - ", with: "_to_", options: .literal, range: nil),
        "pickup_driver_instructions": pickObj?.pickupDriverInst,
        "drop_off_location": pickObj?.dropOffLocation?.nickname,
        "drop_off_date": pickObj?.dropOffDate,
        "drop_off_time": pickObj?.dropOffTime?.lowercased().replacingOccurrences(of: " - ", with: "_to_", options: .literal, range: nil),
        "drop_off_driver_instructions": pickObj?.dropOffDriverInst] as [String: AnyObject]
        
        
        var dict1 = ["drop_off_location": pickObj?.dropOffLocation?.nickname,
                    "drop_off_date": pickObj?.dropOffDate,
                    "drop_off_time": pickObj?.dropOffTime?.lowercased().replacingOccurrences(of: " - ", with: "_to_", options: .literal, range: nil),
                    "drop_off_driver_instructions": pickObj?.dropOffDriverInst] as [String: AnyObject]
        
        if isRescheduled == true {
            dict["reschedule_pickup"] = true as AnyObject
            dict1["reschedule_drop_off"] = true as AnyObject
        }
        
        return editPickInfo == true ? dict : dict1
    }
}
