//
//  AddNewPinViewController.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 23/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//


import UIKit
import MapKit

class AddNewPinViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var setNewLocationTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNewLocationTextField.delegate = self
    }
    
    // MARK: Actions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findOnTheMap(_ sender: UIButton) {
        
        self.view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        
        if let mapString = setNewLocationTextField.text, mapString != "" {
            

            LocationData.sharedInstance.myLocation?.mapString = mapString
            LocationData.sharedInstance.myLocation?.uniqueKey = ParseClient.Constants.UdacityID
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(mapString, completionHandler: {(placemarks, error) in
                if let placemark = placemarks?[0] {
                    LocationData.sharedInstance.myLocation?.latitude = placemark.location!.coordinate.latitude
                    LocationData.sharedInstance.myLocation?.longitude = placemark.location!.coordinate.longitude
                        self.activityIndicator.stopAnimating()

                    let placeNewPinVC = self.storyboard!.instantiateViewController(withIdentifier: "ShareLinkViewController") as! ShareLinkViewController
                    self.navigationController?.pushViewController(placeNewPinVC, animated: true)
                } else {
                    self.activityIndicator.stopAnimating()
                    showAlert(viewController: self, title: "ERROR", message: "Could not geocode your location!", actionTitle: "Dismiss")
                }
            })
            
            
        } else {
            showAlert(viewController: self, title: "ERROR", message: "Location name cannot be empty!", actionTitle: "Dismiss")
        }
    }
    
    // MARK: Singleton shared instance

    class func sharedInstance() -> AddNewPinViewController {
        struct Singleton {
            static let sharedInstance = AddNewPinViewController()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setNewLocationTextField.resignFirstResponder()
        return true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        setNewLocationTextField.resignFirstResponder()
    }
    
}
