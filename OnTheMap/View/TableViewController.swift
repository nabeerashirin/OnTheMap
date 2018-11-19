//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 23/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        tableView.reloadData()
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationData.sharedInstance.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let listCell = tableView.dequeueReusableCell(withIdentifier: "ListTableCell") as UITableViewCell?
 
        listCell?.textLabel?.text = "\(LocationData.sharedInstance.studentLocations[indexPath.row].firstName) \(LocationData.sharedInstance.studentLocations[indexPath.row].lastName)"
        listCell?.detailTextLabel?.text = "\(LocationData.sharedInstance.studentLocations[indexPath.row].mapString)"
        
        return listCell!
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
 
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let mediaURL = URL(string: LocationData.sharedInstance.studentLocations[indexPath.row].mediaURL), UIApplication.shared.canOpenURL(mediaURL) {
            UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
        } else {
            showAlert(viewController: self, title: "ERROR", message: "This student location contains no valid URL to display", actionTitle: "Dismiss")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
 
    class func sharedInstance () -> TableViewController {
        struct Singleton {
            static let sharedInstance = TableViewController()
        }
        return Singleton.sharedInstance
    }
}
