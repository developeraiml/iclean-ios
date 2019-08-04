//
//  SearchLocationVC.swift
//  iClean
//
//  Created by Anand on 04/08/19.
//  Copyright © 2019 Anand. All rights reserved.
//

import UIKit
import MapKit

class SearchLocationVC: UIViewController {

    @IBOutlet weak var searchTableview: UITableView!
    
   fileprivate var searchCompleter = MKLocalSearchCompleter()
   fileprivate var searchResults = [MKLocalSearchCompletion]()
    
    var addressHandler: ( (_ param : [AnyHashable : Any]?)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchCompleter.delegate = self
        
        searchTableview.tableFooterView = UIView()

    }
    

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension SearchLocationVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
    }
}

extension SearchLocationVC: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchTableview.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension SearchLocationVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")
        cell?.textLabel?.text = searchResult.title
        cell?.detailTextLabel?.text = searchResult.subtitle
        return cell ?? UITableViewCell()
    }
}

extension SearchLocationVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            let placeMark =  response?.mapItems[0].placemark
            
            if let handler = self?.addressHandler {
                handler(placeMark?.addressDictionary)
            }
            
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
