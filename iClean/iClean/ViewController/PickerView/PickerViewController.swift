//
//  PickerViewController.swift
//  iClean
//
//  Created by Anand on 03/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

enum pickerType: Int {
    case datePicker
    case timePicker
}

class PickerViewController: UIViewController {

    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    fileprivate var timePickList = ["7am - 8am","8am - 9am","9am - 10am","10am - 11am","11am - 12pm",
                                    "12pm - 1pm","1pm - 2pm","2pm - 3pm","3pm - 4pm",
                                    "4pm - 5pm","5pm - 6pm","6pm - 7pm","7pm - 8pm","8pm - 9pm"]
    
    var type: pickerType = .datePicker
    var selectHandler: ((_ keyName: String,_ sDate: Date?)->Void)?
    
    var selectedTime : String?
    var selectedDate : Date?
    
    fileprivate var dateFormatter = DateFormatter()
    
    fileprivate var selectedString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerView.minimumDate = Date()

        if type == .datePicker {
            self.pickerView.isHidden = true
            dateFormatter.dateFormat = "yyyy-MM-dd"
            selectedString = dateFormatter.string(from: Date())
            
            if selectedDate != nil {
                selectedString = dateFormatter.string(from: selectedDate ?? Date())
            }
            
        } else {
            self.datePickerView.isHidden = true
             selectedString = timePickList[0]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if selectedTime != nil {
            let index = timePickList.firstIndex(of: selectedTime ?? "")
            selectedString = timePickList[index ?? 0]
            self.pickerView.selectRow(index ?? 0, inComponent: 0, animated: false)
        }
        
        if selectedDate != nil {
            datePickerView.setDate(selectedDate ?? Date(), animated: false)
        } else {
            selectedDate = Date()
        }
    }
    
    
    fileprivate func removeView() {
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    
    @IBAction func doneAction(_ sender: Any) {
        
        if let handler = selectHandler {
            handler(selectedString, selectedDate)
        }
        
        removeView()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        removeView()
    }
    
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        selectedDate = sender.date
        selectedString = dateFormatter.string(from: sender.date)
    }
    
}

extension PickerViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timePickList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return timePickList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedString = timePickList[row]
//        if let handler = selectHandler {
//            handler(timePickList[row])
//        }
        
    }
}
