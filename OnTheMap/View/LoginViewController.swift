//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 20/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//


import UIKit
import MapKit

class LoginViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    // MARK: properties
    let locationManager = CLLocationManager()
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLocationManager()
        
        // Assigning delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset login-password fields
        emailTextField.text = nil
        passwordTextField.text = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Actions
    
    @IBAction private func login(_ sender: UIButton) {
        
        
      
        UdacityClient.sharedInstance().getSessionID(userName: emailTextField.text!, password: passwordTextField.text!, loginVC: self, completionHandlerForLogin: {(success, error) in
            if success {
                UdacityClient.sharedInstance().getUserDetails(completionHandlerForUserDetails: {(success, error) in
                    if success {
                        ParseClient.sharedInstance().getAllStudentLocations(completionHandlerForGetAllStudentLocations: {(success, error) in
                            if success {
                                performUIUpdatesOnMain {
                                    self.completeLogin()
                                }
                            } else {
                                performUIUpdatesOnMain {
                                    showAlert(viewController: self, title: "ERROR", message: error?.localizedDescription, actionTitle: "Dismiss")
                                }
                            }
                        })
                    } else {
                        performUIUpdatesOnMain {
                            showAlert(viewController: self, title: "ERROR", message: error?.localizedDescription, actionTitle: "Dismiss")
                        }
                    }
                })
            } else {
                performUIUpdatesOnMain {
                    
                    showAlert(viewController: self, title: "ERROR", message: error?.localizedDescription, actionTitle: "Dismiss")
                }
            }
        })
    }
    
    private func completeLogin() {
        let navigationManagerController = storyboard!.instantiateViewController(withIdentifier: "NavigationManagerController") as! UINavigationController
            self.present(navigationManagerController, animated: true, completion: nil)
    }
    
    
    func setUpLocationManager(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        CLLocationManager.locationServicesEnabled()
        locationManager.startUpdatingLocation()
        
    }
    
    // MARK: Location Manager Delegate Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        LocationData.sharedInstance.myLocation?.latitude = userLocation.coordinate.latitude
        LocationData.sharedInstance.myLocation?.longitude = userLocation.coordinate.longitude
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}

