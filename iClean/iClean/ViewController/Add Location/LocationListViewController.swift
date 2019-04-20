//
//  LocationListViewController.swift
//  iClean
//
//  Created by Anand on 28/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class LocationListViewController: BaseViewController {

    @IBOutlet weak var placeHolderAddress: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    fileprivate var addressList : [UserAddress] = []
    
    var addressSelectHandler : ((UserAddress)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableview.estimatedRowHeight = UITableView.automaticDimension
        
        tableview.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchLocation()

    }
    
    fileprivate func fetchLocation() {
        
        showLoadSpinner(message: "Loading Address ...")

        let api  = LocationNetworkModel()
        api.fetchAddress { (success, result, error) in
            
          //  debugPrint(result)
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideLoadSpinner()
                
                if success {
                    
                    let message = result?["message"] as? String
                    
                    if result?["status"] as? Int == 200 {
                        
                         if let innerData = result?["data"] as? [String: AnyObject] {
                            
                            strongSelf.addressList.removeAll()
                            
                            for adress in innerData["addresses"] as! [[String: AnyObject]] {
                                
                                let address = UserAddress(with: adress)
                                strongSelf.addressList.append(address)
                            }
                            
                            strongSelf.tableview.reloadData()
                        }
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api Error")

                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddLocationVC"
        {
            // Store the transaction whose details we wish to view
            if let viewController = segue.destination as? AddLocationViewController {
                viewController.addressHandler = { isAddressAdded in
                   // self.fetchLocation()
                }
            }
        }
        
    }

}


extension LocationListViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let address = addressList[indexPath.row]
            showLoadSpinner(message: "Deleting Address ...")

            let api = LocationNetworkModel()
            api.deleteAddress(addressId: address.uid!) { (success, result, error) in
                
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.hideLoadSpinner()
                    
                    if success {
                        
                        let message = result?["message"] as? String
                        
                        if result?["status"] as? Int == 204 {
                            
                            strongSelf.addressList.remove(at: indexPath.row)
                            strongSelf.tableview.reloadData()

                        }
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")

                    } else {
                        strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                    }
                });
                
            }

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.placeHolderAddress.isHidden = self.addressList.count == 0 ? false : true
        return self.addressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationlistCell") as? LocationlistCell
        
        let address = addressList[indexPath.row]
        
        cell?.nickName.text = address.nickname?.capitalized
        
        cell?.address.text =  "\(address.address_1 ?? ""), \(address.apartment_name ?? ""), \(address.city ?? ""), \(address.state ?? ""), \(address.zip_code ?? "") ".capitalized
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let address = addressList[indexPath.row]
        
        if let handler = addressSelectHandler {
            handler(address)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "AddLocationVC") as? AddLocationViewController
            vc?.address = address
            vc?.addressHandler = { [weak self] isUpdated in
                
//                guard let strongSelf = self else {
//                    return
//                }
               // strongSelf.fetchLocation()
            }
            self.navigationController?.pushViewController(vc!, animated: true)
        }

    }
    
}
