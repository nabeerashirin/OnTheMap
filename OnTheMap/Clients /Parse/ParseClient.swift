//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 20/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
 
    var sessionID: String? = nil
    var userID: String? = nil
    
    // MARK: Methods
   
    func taskForMethod(_ method: MethodTypes, withURL url: URL, httpHeaderFieldValue httpHeader: [String:String], httpBody: String?, completionHandlerForTask: @escaping (_ result: AnyObject?, _ error: NSError?) throws -> Void ) -> URLSessionDataTask {
        
        // Request
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue
        for (field, value) in httpHeader {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        if let httpBody = httpBody {
            request.httpBody = httpBody.data(using: String.Encoding.utf8)
        }
        
      
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
         
            func Error(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey:error]
                try! completionHandlerForTask(nil, NSError(domain: "taskForMethod", code: 1, userInfo: userInfo))
            }
            

            guard error == nil else {
                Error("Request returned the following error: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    Error("Request returned a status code other than 2xx")
                return
            }
            
            // data retuned
            guard var Data = data else {
                Error("Request returned no data")
                return
            }
            
            // removing first 5 symbols
            if url.description.contains("www.udacity.com/api") {
                let range = Range(5 ..< Data.count)
                Data = Data.subdata(in: range)
            }
            
            var serializedData: AnyObject! = nil
            do {
                serializedData = try JSONSerialization.jsonObject(with: Data, options: .allowFragments) as AnyObject
                try! completionHandlerForTask(serializedData, nil)
            } catch {
                Error("Could not parse data")
                return
            }
        })
        task.resume()
        return task
    }
    
    //function to create a URL
    func makeURL(apiHost: String, apiPath: String, withExtension pathExtension: String?, parameters: [String:String]?) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = apiHost
        components.path = apiPath + (pathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: value)
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    // singleton shared instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}

/*
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
 */
