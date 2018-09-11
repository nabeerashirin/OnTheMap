//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 20/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//

import Foundation


class UdacityClient: NSObject {
    
    // MARK: Properties
    var sessionID: String? = nil
    var userID: String? = nil
    
    
    // MARK: Get Session & User IDs
    // Send Request and retrieve Session ID & User ID
    func getSessionID(userName: String, password: String,loginVC: LoginViewController, completionHandlerForLogin: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        guard userName != "", password != "" else {
            completionHandlerForLogin(false, NSError(domain: "getSessionAndUserID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Empty f5rLogin and/or Password!"]))
            return
        }
        
        let url = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.UdacityApiHost, apiPath: ParseClient.Constants.UdacityApiPath, withExtension: "/session", parameters: nil)
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes(rawValue: "POST")!, withURL: url, httpHeaderFieldValue: [ParseClient.JSONHeaderField.accept:ParseClient.JSONHeaderValues.appJSON, ParseClient.JSONHeaderField.contentType:ParseClient.JSONHeaderValues.appJSON], httpBody: "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}", completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                 let returnError = self.handleError(error)
                completionHandlerForLogin(false, returnError)
                return
            }
            
            let postSession = data as! [String:AnyObject]
            
            // Set client shared instance's property: sessionID
            let sessionInfo = postSession["session"] as! [String:AnyObject]
            if let sessionID = sessionInfo["id"] as? String {
                ParseClient.sharedInstance().sessionID = sessionID
            } else {
                completionHandlerForLogin(false, NSError(domain: "getSessionAndUserID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot retrieve info: id"]))
            }
            
            // Set client shared instance's property: userID
            let accountInfo = postSession["account"] as! [String:AnyObject]
            if let userID = accountInfo["key"] as? String {
                ParseClient.sharedInstance().userID = userID
            } else {
                completionHandlerForLogin(false, NSError(domain: "getSessionAndUserID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot retrieve info: key"]))
            }
            
            // Launch completion handler with parms for successful option
            completionHandlerForLogin(true, nil)
        })
    }
    
    // MARK: Retrieve User Info
    // Retrieve initial user information: first name and last name
    func getUserDetails(completionHandlerForUserDetails: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        let urlForGetUserInfo = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.UdacityApiHost, apiPath: ParseClient.Constants.UdacityApiPath, withExtension: "/users/\(ParseClient.sharedInstance().userID!)", parameters: nil)
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes(rawValue: "GET")!, withURL: urlForGetUserInfo, httpHeaderFieldValue: [:], httpBody: nil, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForUserDetails(false, NSError(domain: "getInitialUserInfo", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForUserDetails(false, error)
                }
                return
            }
            let getUserData = data as! [String:AnyObject]
            
            // Set client shared instance's properties: user first & last names
            let userInfo = getUserData["user"] as! [String:AnyObject]
            if let userFirstName = userInfo["first_name"] as? String, let userLastName = userInfo["last_name"] as? String {
                
                // Make parameteres dictionary. Set lat/long & mediaURL to defaults (will be changed at the next scene)
            let parameters = ["firstName":userFirstName,
                                               "lastName":userLastName,
                                               "latitude":ParseClient.MapViewConstants.defaultLatitude,
                                               "longitude":ParseClient.MapViewConstants.defaultLongitude,
                                               "mediaURL":ParseClient.MapViewConstants.defaultMediaURL] as [String:AnyObject]
 
                // Init Model's 'myLocation' property
                LocationData.sharedInstance.myLocation = StudentLocation(parameters)
                
                completionHandlerForUserDetails(true, nil)
            } else {
                completionHandlerForUserDetails(false, NSError(domain: "getInitialUserInfo", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot retrieve user info: first_name, last_name)"]))
            }
        })
    }
    
   //Error handling
    
    func handleError(_ error: NSError?)-> NSError{
        
        let returnError: NSError
        if (error?.description.contains("offline"))! {
             returnError = NSError(domain: "getSessionAndUserID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"])
        } else {
            returnError = error!
        }
        return returnError
    }
    
    // Make a singleton shared instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}

