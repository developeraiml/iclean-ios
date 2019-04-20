//
//  OrderHistoryViewController.swift
//  iClean
//
//  Created by Anand on 01/11/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class OrderHistoryViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var orderPlaceHolder: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    fileprivate var orderList : [order] = []
    fileprivate var loadMore : Bool = true
    fileprivate var offset : Int = 0
    fileprivate let refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl.addTarget(self, action: #selector(refetchOrderHistory), for: .valueChanged)
        self.tableview.insertSubview(self.refreshControl, at: 0)
        
        self.tableview.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        
        offset = 0
        orderList.removeAll()
        fetchOrderHistory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    @objc fileprivate func refetchOrderHistory() {
        offset = 0
        fetchOrderHistory()
    }
    
    @objc fileprivate func fetchOrderHistory(){
        
        showLoadSpinner(message: "Loading Orders ...")
        
        let api = OrderNetworkModel()
        api.fetchOrderHistory(offset: "\(offset)") { (success, response, error) in
            
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if strongSelf.offset == 0 {
                    strongSelf.orderList.removeAll()
                }
                strongSelf.hideLoadSpinner()
                strongSelf.refreshControl.endRefreshing()

                if success {
                    
                    let message = response?["message"] as? String
                    
                    if response?["status"] as? Int == 401 {
                        
                        strongSelf.presentAlert(title: nil, message: "Something went worng", completion: { (status) in
                            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                                appDel.switchToLogin()
                            }
                        })
                        
                    } else if response?["status"] as? Int == 200 {
                        
                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            if let orders = (innerData["orders"] as? [[String: AnyObject]]) {
                                
                                for ord in orders {
                                    
                                    let obj = order(with: ord)
                                    
                                    strongSelf.orderList.append(obj)
                                }
                                
                                strongSelf.loadMore = false
                                
                                if orders.count == 10 {
                                    strongSelf.loadMore = true
                                    strongSelf.offset += 10
                                }
                               
                            }
                            
                          
                            strongSelf.tableview.reloadData()
                        }
                    } 
                    else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                        
                    }
                } else {
                    
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                }
                

            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.orderPlaceHolder.isHidden = orderList.count == 0 ? false : true
        return orderList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: GeneralConstants.orderHistoryCell) as? OrderHistoryCell
        
        let ord = self.orderList[indexPath.row]
        cell?.dateLabel.text = ord.dropOffDate
        
        if ord.ordStatus != .Delivery {
            cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell1") as? OrderHistoryCell
            
            cell?.amountLabel.text = "#\(ord.uid ?? "") - \(ord.status ?? "")"
            cell?.dateLabel.text = ord.pickupDate
        } else {
            cell?.updateRating(rating: ord.rating)
            cell?.amountLabel.text = "$\(ord.orderCost ?? 0)"
        }
        
        cell?.historyDesc.text = ord.serviceNotes?.capitalized
        
        if indexPath.row >= (orderList.count - 2) && loadMore == true {
            loadMore = false
            fetchOrderHistory()
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let order = self.orderList[indexPath.row]
        return order.ordStatus == .OrderPlaced ? 90 : 100
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let order = self.orderList[indexPath.row]
        
        if order.ordStatus != .Delivery {
            let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.orderStatusVC) as? OrderStatusViewController
            vc?.orderDetails = order
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            
            if order.isPaymentMade == false {
                let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.receiptVC) as? ReceiptViewController
                vc?.orderDetails = order
                self.navigationController?.pushViewController(vc!, animated: true)
            } else if order.rating == -1 {
                
                let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.writeReviewVC) as? WriteReviewViewController
                vc?.orderDetails = order
                navigationController?.pushViewController(vc!, animated: true)
            }
            else {
                
                let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.reviewVC) as? ReviewViewController
                vc?.orderDetials = order
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
            
        }
    }

   
}
