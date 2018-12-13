//
//  OrderStatusViewController.swift
//  iClean
//
//  Created by Anand on 04/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderStatusViewController: BaseViewController {

    @IBOutlet weak var orderStatusView: OrderStatusView!
    @IBOutlet weak var orderStatusLbl: UILabel!
    
    var orderDetails : order?
    
    var timer: Timer?
    
    fileprivate var rescheduleVC : RescheduleViewController?
    fileprivate var isFreshLaunch : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateOrderStatus()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       startTimer()
        
        if self.rescheduleVC != nil && isFreshLaunch == false {
            removeRescheduleView()
        }

        isFreshLaunch = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
       stopTimer()
    }
    
    
    
    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(refreshOrderDetails), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
    
   
    @IBAction func backActions(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc fileprivate func refreshOrderDetails() {
        
        if let orderId = orderDetails?.uid {
            let api = OrderNetworkModel()
            
            api.retreiveOrder(orderId: orderId) { (success, response, error) in
                
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    if success {
                        let message = response?["message"] as? String

                        if response?["status"] as? Int == 401 {
                            
                            strongSelf.presentAlert(title: nil, message: "Something went wrong", completion: { (status) in
                                
                               if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                   appDel.switchToLogin()
                                }
                                
                            })
                            
                        } else if response?["status"] as? Int == 200 {
                            
                            if let innerData = response?["data"] as? [String: AnyObject] {
                                let ord = order(with: innerData)
                                strongSelf.orderDetails = ord
                                
                                strongSelf.updateOrderStatus()
                            }
                        } else if response?["status"] as? Int == 404 {
                            strongSelf.stopTimer()
                            strongSelf.presentAlert(title: nil, message: message ?? "Api error", completion: { (status) in
                                strongSelf.navigationController?.popToRootViewController(animated: true)

                            })
                            
                        }
                        
                    }
                })
            }
        }
        
    }
    
    @IBAction func newOrderAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.orderVC) as? OrderViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func viewEditOrderAction(_ sender: Any) {
        
        openEditOrderScreen(isRescheduled: false, withPickDrop: orderDetails?.ordStatus == .OrderPlaced ? true : false)
    }
    
    func openEditOrderScreen(isRescheduled : Bool, withPickDrop pickup: Bool) {
        let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.orderUpdateVC) as? OrderUpdateViewController
        
        vc?.editPickInfo = pickup
        vc?.pickObj = orderDetails
        vc?.isRescheduled = isRescheduled
    
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func updateOrderStatus() {
        orderStatusView.updateOrderStatus(status: orderDetails?.ordStatus ?? .OrderPlaced)

        switch orderDetails?.ordStatus {
        case .OrderPlaced?:
            self.orderStatusLbl.text = "Your order is confirmed and pick up team will reach there soon."
        case .OrderPickup?:
            self.orderStatusLbl.text = "Your order has been picked up by our team."
        case .Cleaning?:
            self.orderStatusLbl.text = "Your order is being processed."
        default:
            self.orderStatusLbl.text = "Your order is out for delivery."
        }
        
        if orderDetails?.pickupDriverStatus != .PickupAssigned && orderDetails?.dropOffDriverStatus == .DropOffAssigned {
            
            if orderDetails?.pickupDriverStatus == .OrderNotPicked {
                
                stopTimer()
                
                if self.rescheduleVC == nil {
                    let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.rescheduleVC) as? RescheduleViewController
                    
                    vc?.driverNotes = orderDetails?.pickupDriverNotes
                    vc?.orderId = orderDetails?.uid ?? "0"
                    
                    if orderDetails?.pickupfailed == 1 && orderDetails?.reschedulePickup == "1" {
                        vc?.showOnlyCancel = true
                    }
                    
                    vc?.rescheduleHandler = { [weak self]status in
                        self?.openEditOrderScreen(isRescheduled: true, withPickDrop: true)
                    }
                    
                    vc?.willMove(toParent: self)
                    self.view.addSubview(vc!.view)
                    self.addChild(vc!)
                    vc!.didMove(toParent: self)
                    
                    self.rescheduleVC = vc
                }
                

            } else {
                
                removeRescheduleView()


            }
        } else if orderDetails?.dropOffDriverStatus != .DropOffAssigned {
            
             if orderDetails?.dropOffDriverStatus == .OrderNotDropped  {
                
                stopTimer()
                
                if self.rescheduleVC == nil  {
                    let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.rescheduleVC) as? RescheduleViewController
                    
                    vc?.driverNotes = orderDetails?.dropOffDriverNotes
                    vc?.orderId = orderDetails?.uid ?? "0"
                    vc?.isPickMessage = false
                    
                    vc?.rescheduleHandler = { [weak self] status in
                        self?.openEditOrderScreen(isRescheduled: true, withPickDrop: false)
                    }
                    vc?.willMove(toParent: self)
                    self.view.addSubview(vc!.view)
                    self.addChild(vc!)
                    vc!.didMove(toParent: self)
                    
                    self.rescheduleVC = vc
                }
                

             } else {
                removeRescheduleView()
                
                 if orderDetails?.dropOffDriverStatus == .OrderDropped  {
                    if orderDetails?.ordStatus == .Delivery ||  orderDetails?.ordStatus == .Completed {
                        stopTimer()
                        showPopView(popupType: .Complete) { [weak self] (status) in
                            self?.openReceiptScreen()
                        }
                    }
                }

            }
            
        }
        else {
            removeRescheduleView()
            
            if orderDetails?.ordStatus == .Delivery ||  orderDetails?.ordStatus == .Completed {
                stopTimer()
                showPopView(popupType: .Complete) { [weak self] (status) in
                    self?.openReceiptScreen()
                }
            }
        }
    }
    
    func removeRescheduleView() {
        if self.rescheduleVC != nil {
            self.rescheduleVC?.willMove(toParent: nil)
            self.rescheduleVC?.view.removeFromSuperview()
            self.rescheduleVC?.removeFromParent()
            self.rescheduleVC = nil
            
        }
    }
    
    func openReceiptScreen() {
        
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: GeneralConstants.receiptVC) as? ReceiptViewController
            vc?.orderDetails = self.orderDetails
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
}
