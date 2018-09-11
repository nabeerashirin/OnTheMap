//
//  ParsingFunctions.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 20/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//

import Foundation

// Functions for extracting required data from serialized JSONs
extension ParseClient {
    

    // MARK: Get all Users locations
    // Get a full list of Student Locations
    func getAllStudentLocations(completionHandlerForGetAllStudentLocations: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        // Extensions for URL: limit & order
        let urlForGetAllStudentLocations = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.ParseApiHost, apiPath: ParseClient.Constants.ParseApiPath, withExtension: nil, parameters: [ParseClient.Constants.ParseAPILimit:String(ParseClient.Constants.LimitLocations), ParseClient.Constants.ParseAPIOrder: "-updatedAt"])
        //let urlForGetAllStudentLocations = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.ParseApiHost, apiPath: ParseClient.Constants.ParseApiPath, withExtension: nil, parameters: nil)
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.get, withURL: urlForGetAllStudentLocations, httpHeaderFieldValue: ParseClient.JSONHeaderCommon.jsonHeaderCommonParse, httpBody: nil, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForGetAllStudentLocations(false, NSError(domain: "getAllStudentLocations", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForGetAllStudentLocations(false, error)
                }
                return
            }
            
            let locationsData = data as! [String:AnyObject]
            guard let arrayOfLocationDicts = locationsData["results"] as? [[String:AnyObject]] else {
                completionHandlerForGetAllStudentLocations(false, NSError(domain: "getAllStudentsLocations", code: 1, userInfo: [NSLocalizedDescriptionKey:"Could not parse locations data"]))
                return
            }
            
            // Clean the storage array in order to prevent duplications:
            LocationData.sharedInstance.studentLocations = []
            
            // 'location' in the next iteration is either a valid location record (dict [String:AnyObject]) or invalid one
            for location in arrayOfLocationDicts {
                
                // If failable init succeed then append location to the main array, if not (== nil) just skip
                if let studentLocation = StudentLocation(location) {
                    LocationData.sharedInstance.studentLocations.append(studentLocation)
                }
            
            }
            completionHandlerForGetAllStudentLocations(true,nil)
            })
    }
    
    // MARK: Delete a session ID (log out)
    func deleteSessionID(completionHandlerForDeleteSessionID: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        let urlForDeleteSessionID = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.UdacityApiHost, apiPath: ParseClient.Constants.UdacityApiPath, withExtension: "/session", parameters: [:])
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookiesStorage = HTTPCookieStorage.shared
        for cookie in sharedCookiesStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        var headerParameters = [String:String]()
        if let xsrfCookie  = xsrfCookie {
            headerParameters[ParseClient.JSONHeaderField.xsrfToken] = xsrfCookie.value
        }
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.delete, withURL: urlForDeleteSessionID, httpHeaderFieldValue: headerParameters, httpBody: nil, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForDeleteSessionID(false, NSError(domain: "deleteSessionID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForDeleteSessionID(false, error)
                }
                return
            }
            
            let postSession = data as! [String:AnyObject]
            let sessionInfo = postSession["session"] as! [String:AnyObject]
            if let sessionID = sessionInfo["id"] as? String {
                print("DELETED: ", sessionID)
                completionHandlerForDeleteSessionID(true, nil)
            } else {
                completionHandlerForDeleteSessionID(false, NSError(domain: "deleteSessionID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot delete session ID"]))
            }
        })
    }
    
    // MARK: Post a new location
    func postNewLocation(mapString: String, mediaURL: String, latitude:String, longitude: String, completionHandlerForPostNewLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        let urlForPostNewLocation = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.ParseApiHost, apiPath: ParseClient.Constants.ParseApiPath, withExtension: nil, parameters: nil)
        
        var headerParameters = ParseClient.JSONHeaderCommon.jsonHeaderCommonParse
        headerParameters[ParseClient.JSONHeaderField.contentType] = ParseClient.JSONHeaderValues.appJSON
      
        let jsonBody = "{\"uniqueKey\": \"\(ParseClient.Constants.UdacityID)\",\"firstName\": \"\(LocationData.sharedInstance.myLocation!.firstName)\", \"lastName\": \"\(LocationData.sharedInstance.myLocation!.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.post, withURL: urlForPostNewLocation, httpHeaderFieldValue: headerParameters, httpBody: jsonBody, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForPostNewLocation(false, NSError(domain: "postNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForPostNewLocation(false, error)
                }
                return
            }
            
            let sessionInfo = data as! [String:AnyObject]
            if let objectID = sessionInfo["objectId"] {
                LocationData.sharedInstance.myLocation?.objectID = (objectID as! String)
                completionHandlerForPostNewLocation(true, nil)
            } else {
                completionHandlerForPostNewLocation(false, NSError(domain: "postNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot post a new location"]))
            }
        })
    }
    
    // MARK: Replace (put) existing location
    func putNewLocation(locationIDToReplace: String, mapString: String, mediaURL: String, latitude:String, longitude: String, completionHandlerForPutNewLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        let urlForPutNewLocation = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.ParseApiHost, apiPath: ParseClient.Constants.ParseApiPath, withExtension: "/\(locationIDToReplace)", parameters: nil)
        
        var headerParameters = ParseClient.JSONHeaderCommon.jsonHeaderCommonParse
        headerParameters[ParseClient.JSONHeaderField.contentType] = ParseClient.JSONHeaderValues.appJSON
        
           let jsonBody = "{\"uniqueKey\": \"\(ParseClient.Constants.UdacityID)\", \"firstName\": \"\(LocationData.sharedInstance.myLocation!.firstName)\", \"lastName\": \"\(LocationData.sharedInstance.myLocation!.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"

        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.put, withURL: urlForPutNewLocation, httpHeaderFieldValue: headerParameters, httpBody: jsonBody, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForPutNewLocation(false, NSError(domain: "putNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForPutNewLocation(false, error)
                }
                return
            }
            
            let sessionInfo = data as! [String:AnyObject]
            if let _ = sessionInfo["updatedAt"] {
                completionHandlerForPutNewLocation(true, nil)
            } else {
                completionHandlerForPutNewLocation(false, NSError(domain: "putNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot replace an existing location"]))
            }
        })
    }
}

