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

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var doneButton: UIButton!
    fileprivate var timePickList = ["7am - 8am","8am - 9am","9am - 10am","10am - 11am","11am - 12pm",
                                    "12pm - 1pm","1pm - 2pm","2pm - 3pm","3pm - 4pm",
                                    "4pm - 5pm","5pm - 6pm","6pm - 7pm","7pm - 8pm","8pm - 9pm"]
    
    fileprivate var filterPickerList: [String]?
    
    var type: pickerType = .datePicker
    var selectHandler: ((_ dateString: String?,_ timeString: String?,_ sDate: Date?)->Void)?
    
    var selectedTime : String?
    var selectedDateStr : String?
    var selectedDate : Date?
    
    fileprivate var dateFormatter = DateFormatter()
    
    fileprivate var selectedString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerView.minimumDate = Date()
        errorMessage.isHidden = true


        if type == .datePicker {
            self.pickerView.isHidden = true
            dateFormatter.dateFormat = "yyyy-MM-dd"
            selectedString = dateFormatter.string(from: Date())
            
            if selectedDate != nil {
                selectedString = dateFormatter.string(from: selectedDate ?? Date())
            }
            selectedDateStr = selectedString

        } else {
            self.datePickerView.isHidden = true
             selectedString = timePickList[0]
            
            if let sDate = selectedDate {
               
                let date1 = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                if  date1 > sDate {
                    pickerView.isHidden = true
                    errorMessage.text = "In order to update the time slot.\nPlease change the order date."
                    errorMessage.isHidden = false
                    doneButton.isHidden = true
                    
                }
            }
        }
        
        let cal = Calendar.current
        
        if let sDate = selectedDate, type != .datePicker {
            
            let calendar = Calendar.current
            var hour = calendar.component(.hour, from: sDate)
            var minute = calendar.component(.minute, from: sDate)
            var seconds = calendar.component(.second, from: sDate)

            if sDate > Date() {
                hour = 0
                minute = 0
                seconds = 0
            }
            
            let date1 = Calendar.current.date(bySettingHour: hour, minute: minute, second: seconds, of: sDate)!
            
            let date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: sDate)!
            
            let date2 = Date(timeIntervalSince1970: date.timeIntervalSince1970)
            
            let components = cal.dateComponents([.hour,.minute], from: date1, to: date2)
            let diff = components.hour!
            let mdiff = components.minute!
            
            self.filterPickerList = timePickList
            
            if diff <= 12 {
                let difference = (diff >= 0 && mdiff >= 0) ? (diff + 1) : 0
                
                let filterSlice = timePickList.suffix(difference)
                debugPrint(Array(filterSlice))
                self.filterPickerList = Array(filterSlice)
                
                if filterSlice.count == 0 {
                    selectedDate =  Calendar.current.date(byAdding: .day, value: 1, to: sDate)
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    selectedDateStr = dateFormatter.string(from: selectedDate ?? Date())
                    
                    pickerView.isHidden = true
                    errorMessage.isHidden = false
                }
            }
           
        }
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if selectedTime != nil {
            let index = filterPickerList?.firstIndex(of: selectedTime ?? "")
            selectedString = filterPickerList?[index ?? 0] ?? timePickList[0]
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
        
         if let sDate = selectedDate, type == .datePicker {
              let currentDate = Date()
            if currentDate > sDate {
                updateDatePickerFor(date: currentDate)
            }
        }
        
        if let handler = selectHandler {
            handler(selectedDateStr,selectedString, selectedDate)
        }
        
        removeView()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        removeView()
    }
    
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDatePickerFor(date: sender.date)
    }
    
    fileprivate func updateDatePickerFor(date: Date) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        selectedDate = date
        selectedDateStr = dateFormatter.string(from: date)
        selectedString = dateFormatter.string(from: date)
    }
    
}

extension PickerViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterPickerList?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return filterPickerList?[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if filterPickerList?.count != 0 {
            selectedString = filterPickerList?[row] ?? timePickList[0]
        } else {
            
             if let sDate = selectedDate, type != .datePicker {
                selectedDate =  Calendar.current.date(byAdding: .day, value: 1, to: sDate)
                dateFormatter.dateFormat = "yyyy-MM-dd"
                selectedDateStr = dateFormatter.string(from: selectedDate ?? Date())
            }
        }
//        if let handler = selectHandler {
//            handler(timePickList[row])
//        }
        
    }
}
