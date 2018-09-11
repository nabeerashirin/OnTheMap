//
//  ShareLinkViewController.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 23/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//


import UIKit
import MapKit

class ShareLinkViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mediaURLLabel: UITextField!
    @IBOutlet weak var placeNewPinMapView: MKMapView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get user's coordinated from the Model
        let myLatitude = CLLocationDegrees(LocationData.sharedInstance.myLocation!.latitude)
        let myLongitude = CLLocationDegrees(LocationData.sharedInstance.myLocation!.longitude)
        let myCoordinate = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        
        // Make Map annotation from Model data
        let myLocationAnnotation = MKPointAnnotation()
        myLocationAnnotation.coordinate = myCoordinate
        myLocationAnnotation.title = "\(LocationData.sharedInstance.myLocation!.firstName) \(LocationData.sharedInstance.myLocation!.lastName)"
        myLocationAnnotation.subtitle = "\(LocationData.sharedInstance.myLocation!.mediaURL)"
        
        placeNewPinMapView.addAnnotation(myLocationAnnotation)
        
        // Set mapView's region to match user's location
        let region = MKCoordinateRegionMakeWithDistance(myCoordinate, ParseClient.MapViewConstants.mapViewFineScale, ParseClient.MapViewConstants.mapViewFineScale)
        placeNewPinMapView.setRegion(region, animated: true)
        
        // Set text field delegate
        mediaURLLabel.delegate = self
    }
    
    // MARK: Actions
    @IBAction func submitPostNewPin(_ sender: UIButton) {
        guard let mediaURL = mediaURLLabel.text, mediaURL != "" else {
            showAlert(viewController: self, title: "ERROR", message: "Media URL cannot be empty!", actionTitle: "Dismiss")
            return
        }
        
        let latString = String(describing: LocationData.sharedInstance.myLocation!.latitude)
        let longString = String(describing: LocationData.sharedInstance.myLocation!.longitude)
        
        // Check whether location exists
        if LocationData.sharedInstance.locationExists {
            ParseClient.sharedInstance().putNewLocation(locationIDToReplace: LocationData.sharedInstance.myLocation!.objectID, mapString: (LocationData.sharedInstance.myLocation?.mapString)!, mediaURL: mediaURL, latitude: latString, longitude: longString, completionHandlerForPutNewLocation: {(success, error) in
                
                if success {
                    performUIUpdatesOnMain {
                        // Get back to Intial view - Tab bar controller
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    performUIUpdatesOnMain {
                        
                        // Alert: PUT new location failed
                        showAlert(viewController: self, title: "ERROR", message: (error?.userInfo[NSLocalizedDescriptionKey] as! String), actionTitle: "Dismiss")
                    }
                }
                })
        } else {
            ParseClient.sharedInstance().postNewLocation(mapString: (LocationData.sharedInstance.myLocation?.mapString)!, mediaURL: mediaURL, latitude: latString, longitude: longString, completionHandlerForPostNewLocation: {(success, error) in
                
                if success {
                    // Set flag to: location does exist
                    LocationData.sharedInstance.locationExists = true
                    
                    performUIUpdatesOnMain {
                        // Get back to Intial view - Tab bar controller
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    performUIUpdatesOnMain {
                        
                        // Alert: POST new location failed
                        showAlert(viewController: self, title: "ERROR", message: (error?.userInfo[NSLocalizedDescriptionKey] as! String), actionTitle: "Dismiss")
                    }
                }
            })
        }
    }
    
    // MARK: Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mediaURLLabel.resignFirstResponder()
        return true
    }
}
