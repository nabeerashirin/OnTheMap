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

    override func viewDidLoad() {
        super.viewDidLoad()

        let myLatitude = CLLocationDegrees(LocationData.sharedInstance.myLocation!.latitude)
        let myLongitude = CLLocationDegrees(LocationData.sharedInstance.myLocation!.longitude)
        let myCoordinate = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        

        let myLocationAnnotation = MKPointAnnotation()
        myLocationAnnotation.coordinate = myCoordinate
        myLocationAnnotation.title = "\(LocationData.sharedInstance.myLocation!.firstName) \(LocationData.sharedInstance.myLocation!.lastName)"
        myLocationAnnotation.subtitle = "\(LocationData.sharedInstance.myLocation!.mediaURL)"
        
        placeNewPinMapView.addAnnotation(myLocationAnnotation)
        

        let region = MKCoordinateRegionMakeWithDistance(myCoordinate, ParseClient.MapViewConstants.mapViewFineScale, ParseClient.MapViewConstants.mapViewFineScale)
        placeNewPinMapView.setRegion(region, animated: true)
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

        if LocationData.sharedInstance.locationExists {
            ParseClient.sharedInstance().putNewLocation(locationIDToReplace: LocationData.sharedInstance.myLocation!.objectID, mapString: (LocationData.sharedInstance.myLocation?.mapString)!, mediaURL: mediaURL, latitude: latString, longitude: longString, completionHandlerForPutNewLocation: {(success, error) in
                
                if success {
                    performUIUpdatesOnMain {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    performUIUpdatesOnMain {
                        showAlert(viewController: self, title: "ERROR", message: (error?.userInfo[NSLocalizedDescriptionKey] as! String), actionTitle: "Dismiss")
                    }
                }
                })
        } else {
            ParseClient.sharedInstance().postNewLocation(mapString: (LocationData.sharedInstance.myLocation?.mapString)!, mediaURL: mediaURL, latitude: latString, longitude: longString, completionHandlerForPostNewLocation: {(success, error) in
                
                if success {

                    LocationData.sharedInstance.locationExists = true
                    
                    performUIUpdatesOnMain {

                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    performUIUpdatesOnMain {
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
