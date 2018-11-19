//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 23/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var studentLocationsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentLocationsMapView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var annotations = [MKPointAnnotation]()
        for studentLocation in LocationData.sharedInstance.studentLocations {
            let latitude = CLLocationDegrees(studentLocation.latitude)
            let longitude = CLLocationDegrees(studentLocation.longitude)            
            let studentLocationCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
            
            let studentLocationAnnotation = MKPointAnnotation()
            studentLocationAnnotation.coordinate = studentLocationCoordinate
            studentLocationAnnotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            studentLocationAnnotation.subtitle = "\(studentLocation.mediaURL)"
            
            annotations.append(studentLocationAnnotation)
        }
        studentLocationsMapView.addAnnotations(annotations)

        var myCoordinates = CLLocationCoordinate2D(latitude: ParseClient.MapViewConstants.defaultLatitude, longitude: ParseClient.MapViewConstants.defaultLongitude)
        if let myLocation = LocationData.sharedInstance.myLocation {
            myCoordinates = CLLocationCoordinate2D(latitude: myLocation.latitude, longitude: myLocation.longitude)
        }
        let region = MKCoordinateRegionMakeWithDistance(myCoordinates, ParseClient.MapViewConstants.mapViewLargeScale, ParseClient.MapViewConstants.mapViewLargeScale)
        studentLocationsMapView.setRegion(region, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var locationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: ParseClient.MapViewConstants.pinReusableIdentifier)
        
        if locationPinView == nil {
            locationPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ParseClient.MapViewConstants.pinReusableIdentifier)
            locationPinView!.canShowCallout = true
            locationPinView!.tintColor = .blue
            locationPinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            locationPinView!.annotation = annotation
        }
        return locationPinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
 
            var selectedStudentLocation: StudentLocation? = nil
            for location in LocationData.sharedInstance.studentLocations {
                if (location.latitude == view.annotation?.coordinate.latitude) && (location.longitude == view.annotation?.coordinate.longitude) {
                    selectedStudentLocation = location
                }
            }
   
            guard let selectedLocation = selectedStudentLocation else {
                showAlert(viewController: self, title: "ERROR", message: "BAD location!", actionTitle: "Dismiss")
                return
            }
            
            if let mediaURL = URL(string: selectedLocation.mediaURL), UIApplication.shared.canOpenURL(mediaURL) {
                UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
            } else {
                showAlert(viewController: self, title: "ERROR", message: "This student location contains no valid URL to display", actionTitle: "Dismiss")
            }
        }
    }
}
