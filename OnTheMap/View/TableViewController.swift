//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 23/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    // MARK: Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload table data
        tableView.reloadData()
    }
    
    // MARK: TableView Delegate & Data Source functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationData.sharedInstance.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get cell type
        let listCell = tableView.dequeueReusableCell(withIdentifier: "ListTableCell") as UITableViewCell?
        
        // Setup cell
        listCell?.textLabel?.text = "\(LocationData.sharedInstance.studentLocations[indexPath.row].firstName) \(LocationData.sharedInstance.studentLocations[indexPath.row].lastName)"
        listCell?.detailTextLabel?.text = "\(LocationData.sharedInstance.studentLocations[indexPath.row].mapString)"
        
        return listCell!
    }
    
    // Open the associated link (mediaURL) in a Default Browser
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselect row:
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let mediaURL = URL(string: LocationData.sharedInstance.studentLocations[indexPath.row].mediaURL), UIApplication.shared.canOpenURL(mediaURL) {
            UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
        } else {
            showAlert(viewController: self, title: "ERROR", message: "This student location contains no valid URL to display", actionTitle: "Dismiss")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ParseClient.ListViewConstante.tableDefaultHeight
    }
    
    // MARK: TableViewVC singleton shared instance
    class func sharedInstance () -> TableViewController {
        struct Singleton {
            static let sharedInstance = TableViewController()
        }
        return Singleton.sharedInstance
    }
}
