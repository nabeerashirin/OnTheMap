//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 20/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//

import Foundation

struct StudentLocation {
    var objectID: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double

   init?(_ locationDictionary: [String:AnyObject]) {
    
        if let firstName = locationDictionary["firstName"] as? String,
        let lastName = locationDictionary["lastName"] as? String,
        let latitude = locationDictionary["latitude"] as? Double,
        let longitude = locationDictionary["longitude"] as? Double,
        let mediaURL = locationDictionary["mediaURL"] as? String {
            self.firstName = firstName
            self.lastName = lastName
            self.latitude = latitude
            self.longitude = longitude
            self.mediaURL = mediaURL
        } else {
            return nil
        }
        if let objectID = locationDictionary["objectID"] as? String {
            self.objectID = objectID
        } else {
            self.objectID = ""
        }
    
        if let uniqueKey = locationDictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        } else {
            self.uniqueKey = ""
        }
    
        if let mapString = locationDictionary["mapString"] as? String {
            self.mapString = mapString
        } else {
            self.mapString = ""
        }
    }

}

