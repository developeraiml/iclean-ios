//
//  CardListVC.swift
//  iClean
//
//  Created by Anand on 29/10/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree

class CardListViewController: BaseViewController {

    @IBOutlet weak var cardPlaceholder: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    
    fileprivate var cardList : [Card] = []
    
    var selectHandler : ((_ cardId: Int)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableview.tableFooterView = UIView()
        
        
       // backBtn.isSelected = isViewPresented
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllCards()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func addNewCard(_ sender: Any) {
        
        let appDel : AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        if appDel?.isNetworkAvailable() ==  false {
            
            self.presentAlert(title: nil, message: "No Network Found")
            return
        }
        
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: iCleanManager.sharedInstance.brainTreeClientToken , request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
//                // Use the BTDropInResult properties to update your UI
//                // result.paymentOptionType
//                // result.paymentMethod
//                // result.paymentIcon
//                // result.paymentDescription
//
//                debugPrint(result.paymentOptionType)
//                debugPrint(result.paymentMethod) // payment menthod is Nonce
//                debugPrint(result.paymentDescription)
//                debugPrint(result.paymentIcon)
//                debugPrint(result.paymentMethod?.nonce) // payment menthod is Nonce
                
                self.addCard(nonce: result.paymentMethod?.nonce ?? "")
                
                
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    fileprivate func addCard(nonce : String) {
        
        let api = BraintreeNetworkModel()
        api.addCard(nonce) { [weak self] (success, response, error) in
            self?.getAllCards()
        }
    }
    
    fileprivate func getAllCards() {
        
        showLoadSpinner(message: "Fetching cards ...")

        let api = BraintreeNetworkModel()

        api.getAllCards { (success, response, error) in
            
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
                        
                        if let innerData = response?["data"] as? [String: AnyObject] {
                            
                            strongSelf.cardList.removeAll()
                            for card in (innerData["cards"] as? [[String: AnyObject]])! {
                                let obj = Card(with: card)
                                strongSelf.cardList.append(obj)
                            }
                            
                            strongSelf.tableview.reloadData()
                        }
                    } else {
                        strongSelf.presentAlert(title: nil, message: message ?? "Api error")
                        
                    }
                } else {
                    strongSelf.presentAlert(title: nil, message: error?.localizedDescription ?? "Network error")
                    
                }
            })
        }
    }
    
}


extension CardListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.cardPlaceholder.isHidden = (cardList.count == 0) ? false : true
        return cardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: GeneralConstants.cardcell) as? CardCell
        
        let crd = self.cardList[indexPath.row]
        
        cell?.editBtn.isHidden = true
        cell?.cardType.text = (crd.companyName ?? "") + " - " + (crd.expiry ?? "")
        cell?.cardNumber.text = "XXXX-XXXX-XXXX-\(crd.cardNumber ?? "")"
        cell?.nickName.text = crd.nickName
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isViewPresented {
            
            let crd = self.cardList[indexPath.row]

            if let handler = selectHandler {
                handler(crd.cardId ?? 0)
            }
            
            dismiss(animated: true, completion: nil)
        } else {
            
            let vc = storyboard?.instantiateViewController(withIdentifier: GeneralConstants.addCardVc) as? AddCardViewController
            vc?.cardInfo = self.cardList[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
}
