//
//  ViewController.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 23/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//


import UIKit

class TabManagerViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    // Launch VC to add a new pin
    @IBAction func addNewPin(_ sender: UIBarButtonItem) {
        
        if LocationData.sharedInstance.locationExists {
            let pinExistsMessage = UIAlertController(title: "Warning!", message: "Your location already exists. Do you want to overwrite it?", preferredStyle: .alert)
            pinExistsMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            pinExistsMessage.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {control in
                let addNewPinNavigationViewController = self.storyboard!.instantiateViewController(withIdentifier: "NavigationPinController") as! UINavigationController
                self.present(addNewPinNavigationViewController, animated: true, completion: nil)
            }))
            self.present(pinExistsMessage, animated: false, completion: nil)
        } else {
            let addNewPinNavigationViewController = storyboard!.instantiateViewController(withIdentifier: "NavigationPinController") as! UINavigationController
            self.present(addNewPinNavigationViewController, animated: true, completion: nil)
        }
    }
    
    // Refresh button - common for Map and List
    // TODO: Refresh main data storing array in Model - check that update is applied to Map/List VCs
    @IBAction func refreshStudentLocations(_ sender: UIBarButtonItem) {
        ParseClient.sharedInstance().getAllStudentLocations(completionHandlerForGetAllStudentLocations: {(success, error) in
            if success {
                performUIUpdatesOnMain {
                    // Confirm the update with AlertView
                    showAlert(viewController: self, title: "SUCCESS", message: "Database updated", actionTitle: "Dismiss")
                    
                    // Update the table ('list') view
                    TableViewController.sharedInstance().tableView.reloadData()
                    
                    // TODO: Refresh map view
                }
            } else {
                performUIUpdatesOnMain {
                    showAlert(viewController: self, title: "ERROR", message: error?.description, actionTitle: "Dismiss")
                }
            }
        })
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        
        
        ParseClient.sharedInstance().deleteSessionID(completionHandlerForDeleteSessionID: {(success, error) in
            if success {
                print("ID deleted")
                performUIUpdatesOnMain {
                    let logoutController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
                    
                    let yesButton = UIAlertAction(title: "Yes", style: .default, handler: {_ in
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
                        print("cancel")
                    })
                    
                    logoutController.addAction(yesButton)
                    logoutController.addAction(cancelButton)
                    
                    self.present(logoutController, animated: true, completion: nil)
                    
                }
            } else {
                performUIUpdatesOnMain {
                    showAlert(viewController: self, title: "ERROR", message: error?.description, actionTitle: "Dismiss")
                }
            }
        })
        /*
         ParseClient.sharedInstance().deleteSessionID(completionHandlerForDeleteSessionID: {(success, error) in
         if success {
         print("ID deleted")
         performUIUpdatesOnMain {
         self.dismiss(animated: true, completion: nil)
         }
         } else {
         performUIUpdatesOnMain {
         showAlert(viewController: self, title: "ERROR", message: error?.description, actionTitle: "Dismiss")
         }
         }
         })
         
         */
    }
}
