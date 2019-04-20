//
//  NextCustUpdatesVC.swift
//  iClean
//
//  Created by Anand on 07/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class NextCustUpdatesViewController: BaseViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var navtitle: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    
    var order : driverOrder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if order?.type == .OrderPickup {
            self.navtitle.text = "Pick Up"
        } else {
            self.navtitle.text = "Drop Off"
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if order?.type == .OrderPickup {
            updatePickUpDriverStatusInfo()
        } else {
            updateDropOffDriverStatusInfo()
        }
        
    }
    
    @IBAction func showDirectionAction(_ sender: Any) {
        
        var dirAddress = ""
         if order?.type == .OrderPickup {
            if let address =  order?.ordInfo?.pickupLocation {
                dirAddress = "\(address.apartment_name ?? "")+\(address.address_1 ?? ""),\(address.city ?? ""), \(address.state ?? "")-\(address.zip_code ?? "")"
            }
            
         } else {
            if let address =  order?.ordInfo?.dropOffLocation {
                dirAddress = "\(address.apartment_name ?? "")+\(address.address_1 ?? ""),\(address.city ?? ""), \(address.state ?? "")-\(address.zip_code ?? "")"
            }
        }
        
        dirAddress = dirAddress.replacingOccurrences(of:" ", with: "")
        
        UIApplication.shared.open(URL(string:"https://maps.google.com/maps?f=d&daddr=\(dirAddress)&sll=35.6586,139.7454&sspn=0.2,0.1&nav=1")!, options: [:], completionHandler: nil)
  
    }
    
    
    fileprivate func updateDropOffDriverStatusInfo() {
        
        switch order?.ordInfo?.dropOffDriverStatus {
            
        case .DropOffAssigned?:
            self.collectionview.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        case .GetDirection?:
            self.collectionview.scrollToItem(at: IndexPath(item: 1, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        case .LetThemKnow?:
            self.collectionview.scrollToItem(at: IndexPath(item: 2, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        default:
            break
        }
    }
    
    fileprivate func updatePickUpDriverStatusInfo() {
        
        switch order?.ordInfo?.pickupDriverStatus {
            
        case .GetDirection?:
            self.collectionview.scrollToItem(at: IndexPath(item: 1, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        case .LetThemKnow?:
            self.collectionview.scrollToItem(at: IndexPath(item: 2, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        case .OrderPicked?:
            self.collectionview.scrollToItem(at: IndexPath(item: 2, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        default:
            break
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.item {
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomerPreviewCell", for: indexPath) as? CustomerPreviewCell
            
            cell?.customerName.text = order?.customer?.name
            cell?.address.text = "\(order?.address?.address_1 ?? ""), apt #\(order?.address?.apartment_name ?? ""), gate code #\(order?.address?.gate_code ?? ""), \(order?.address?.city ?? ""), \(order?.address?.state ?? "") \(order?.address?.zip_code ?? "")".capitalized
            
            if order?.type == .OrderPickup {
                cell?.pickUpTime.text = "PICK-UP " + (order?.ordInfo?.pickupTime ?? "")
                cell?.specialNotes.text = order?.ordInfo?.pickupDriverInst
                cell?.specialInstructionLbl.text = "SPECIAL PICK UP INSTRUCTIONS"
                
                if let address =  order?.ordInfo?.pickupLocation {
                    cell?.address.text = "\(address.address_1 ?? ""), apt #\(address.apartment_name ?? ""), gate code #\(address.gate_code ?? ""), \(address.city ?? ""), \(address.state ?? "") \(address.zip_code ?? "")".capitalized
                }
                
                
            } else {
                cell?.pickUpTime.text = "DROP-OFF " + (order?.ordInfo?.dropOffTime ?? "")
                cell?.specialNotes.text = order?.ordInfo?.dropOffDriverInst
                cell?.specialInstructionLbl.text = "DROP OFF INSTRUCTIONS"
                cell?.leaveAtDoorman.isHidden = order?.ordInfo?.dropOffLocation?.leaveAtDoorman == true ? false : true
                
                if let address =  order?.ordInfo?.dropOffLocation {
                    cell?.address.text = "\(address.address_1 ?? ""), apt #\(address.apartment_name ?? ""), gate code #\(address.gate_code ?? ""), \(address.city ?? ""), \(address.state ?? "") \(address.zip_code ?? "")".capitalized
                }
                
                
                //debugPrint(order?.ordInfo?.dropOffLocation?.leaveAtDoorman)
            }
            
            cell?.letThemKnowBtn.addTarget(self, action: #selector(letCustomerKnow), for: .touchUpInside)
            return cell!
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GetDirectionCell", for: indexPath) as? GetDirectionCell
            
            cell?.customerName.text = order?.customer?.name
            cell?.address.text = "\(order?.address?.address_1 ?? ""), apt #\(order?.address?.apartment_name ?? ""), gate code #\(order?.address?.gate_code ?? ""), \(order?.address?.city ?? ""), \(order?.address?.state ?? "") \(order?.address?.zip_code ?? "")".capitalized
            
            if order?.type == .OrderPickup {
                cell?.pickUpTime.text = "PICK-UP " + (order?.ordInfo?.pickupTime ?? "")
                cell?.specialNotes.text = order?.ordInfo?.pickupDriverInst
                cell?.specialInstructionLbl.text = "SPECIAL PICK UP INSTRUCTIONS"
                
                if let address =  order?.ordInfo?.pickupLocation {
                    cell?.address.text = "\(address.address_1 ?? ""), apt #\(address.apartment_name ?? ""), gate code #\(address.gate_code ?? ""), \(address.city ?? ""), \(address.state ?? "") \(address.zip_code ?? "")".capitalized
                }
                
              
                
            } else {
                cell?.pickUpTime.text = "DROP-OFF " + (order?.ordInfo?.dropOffTime ?? "")
                cell?.specialNotes.text = order?.ordInfo?.dropOffDriverInst
                cell?.specialInstructionLbl.text = "DROP OFF INSTRUCTIONS"
                cell?.leaveAtDoorman.isHidden = order?.ordInfo?.dropOffLocation?.leaveAtDoorman == true ? false : true
                
                if let address =  order?.ordInfo?.dropOffLocation {
                    cell?.address.text = "\(address.address_1 ?? ""), apt #\(address.apartment_name ?? ""), gate code #\(address.gate_code ?? ""), \(address.city ?? ""), \(address.state ?? "") \(address.zip_code ?? "")".capitalized
                }
                

            }
            
            cell?.getDirectionBtn.addTarget(self, action: #selector(getCustomerDirection), for: .touchUpInside)
            return cell!
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeliveryPickupCell", for: indexPath) as? DeliveryPickupCell
            
            cell?.customerName.text = order?.customer?.name
            cell?.address.text = "\(order?.address?.address_1 ?? ""), apt #\(order?.address?.apartment_name ?? ""), gate code #\(order?.address?.gate_code ?? ""), \(order?.address?.city ?? ""), \(order?.address?.state ?? "") \(order?.address?.zip_code ?? "")".capitalized
            
            cell?.makeCallBtn.addTarget(self, action: #selector(callCustomer), for: .touchUpInside)
            
            if order?.type == .OrderPickup {
                cell?.specialNotes.text = order?.ordInfo?.pickupDriverInst
                cell?.specialInstructionLbl.text = "SPECIAL PICK UP INSTRUCTIONS"
                cell?.bottmTextLbl.text = "Were you able to pick-up the order?"
                
                if let address =  order?.ordInfo?.pickupLocation {
                    
                    cell?.address.text = "\(address.address_1 ?? ""), apt #\(address.apartment_name ?? ""), gate code #\(address.gate_code ?? ""), \(address.city ?? ""), \(address.state ?? "") \(address.zip_code ?? "")".capitalized
                }
                
                
            } else {
                cell?.specialNotes.text = order?.ordInfo?.dropOffDriverInst
                cell?.specialInstructionLbl.text = "DROP OFF INSTRUCTIONS"
                cell?.bottmTextLbl.text = "Were you able to drop-off the order?"
                cell?.leaveAtDoorman.isHidden = order?.ordInfo?.dropOffLocation?.leaveAtDoorman == true ? false : true

                if let address =  order?.ordInfo?.dropOffLocation {
                    
                    cell?.address.text = "\(address.address_1 ?? ""), apt #\(address.apartment_name ?? ""), gate code #\(address.gate_code ?? ""), \(address.city ?? ""), \(address.state ?? "") \(address.zip_code ?? "")".capitalized
                }
                
                
            }
            
            
            cell?.noButton.addTarget(self, action: #selector(noPickAction), for: .touchUpInside)
            cell?.yesButton.addTarget(self, action: #selector(yesPickAction), for: .touchUpInside)
            
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}

extension NextCustUpdatesViewController {
    
    @objc func letCustomerKnow() {
        
        var parameters = ["pickup_driver_status": "driver_clicked_let_them_know_you_are_here"] as [String : AnyObject]
        
        if self.order?.type == .DropOff {
            parameters = ["drop_off_driver_status": "driver_clicked_let_them_know_you_are_here"] as [String : AnyObject]
        }
        
        self.updateOrderStatus(dict: parameters , orderId: order?.ordInfo?.uid ?? "", handler: { [weak self] status in
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.collectionview.scrollToItem(at: IndexPath(item: 2, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            })
        })
        
        
    }
    
    @objc func getCustomerDirection() {
        
        var parameters = ["pickup_driver_status": "driver_got_directions"] as [String : AnyObject]
        
        if self.order?.type == .DropOff {
            parameters = ["drop_off_driver_status": "driver_got_directions"] as [String : AnyObject]
        }
        
        self.updateOrderStatus(dict: parameters , orderId: order?.ordInfo?.uid ?? "", handler: { [weak self] status in
            
            if status {
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionview.scrollToItem(at: IndexPath(item: 1, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                })
            }
            
        })
    }
    
    @objc func noPickAction() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DriverNotesVC") as? DriverNotesViewController
        
        vc?.handler = {[weak self] notes in
            
            var parameters = ["drop_off_driver_status": "driver_not_able_to_dropoff",
                              "notes_by_drop_off_driver": notes.encodeEmoji] as [String : AnyObject]
            
            if self?.order?.type == .OrderPickup {
                parameters = ["pickup_driver_status": "driver_not_able_to_pickup",
                              "notes_by_pickup_driver" : notes.encodeEmoji] as [String : AnyObject]
            }
            
            self?.updateOrderStatus(dict: parameters, orderId: self?.order?.ordInfo?.uid ?? "", handler: { (status) in
                
                if status {
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            
        }
        vc?.willMove(toParent: self)
        self.view.addSubview(vc!.view)
        self.addChild(vc!)
        vc!.didMove(toParent: self)
        
    }
    
    @objc func yesPickAction() {
        
        var parameters = ["drop_off_driver_status": "driver_dropped_off_order"] as [String : AnyObject]
        
        if self.order?.type == .OrderPickup {
            parameters = ["pickup_driver_status": "driver_picked_up_order"] as [String : AnyObject]
            
        }
        
        self.updateOrderStatus(dict: parameters , orderId: order?.ordInfo?.uid ?? "", handler: { [weak self] status in
            
            if status {
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.navigationController?.popViewController(animated: true)
                })
            }
            
        })
        
    }
}

extension NextCustUpdatesViewController {
    
    @objc func callCustomer() {
        
        let phoneString = order?.customer?.phone
        
        if let url = URL(string: "tel://\(phoneString?.replacingOccurrences(of: " ", with: "") ?? "4242942222")") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
        
    }
}

extension NextCustUpdatesViewController {
    
    fileprivate func updateOrderStatus(dict : [String : AnyObject], orderId: String, handler: ((Bool)-> Void)?) {
        
        showLoadSpinner(message: "Updating Orders ...")
        
        let api = DriverNetworkModel()
        api.updateOrderStatus(param: dict, orderId: orderId) { (success, response, error) in
            
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
                        
                        if let handler = handler {
                            handler(true)
                        }
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                        
                        if let handler = handler {
                            handler(false)
                        }
                        
                    }
                } else {
                    if let handler = handler {
                        handler(false)
                    }
                    
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                    
                }
                
            })
        }
    }
}
