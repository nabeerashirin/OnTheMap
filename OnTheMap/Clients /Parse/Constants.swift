//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 20/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//

import Foundation
import UIKit

extension ParseClient {


    struct Constants {
      
        static let ApiScheme = "https"
        static let ParseApiHost = "parse.udacity.com"
        static let UdacityApiHost = "www.udacity.com"
        static let ParseApiPath = "/parse/classes/StudentLocation"
        static let UdacityApiPath = "/api"
        
  
        static let ParseAPILimit = "limit"
        static let LimitLocations = 100
        static let ParseAPIOrder = "order"
        static let UdacityID = "3903878747"
        
    }
    
    struct JSONHeaderField {
        static let contentType = "Content-Type"
        static let accept = "Accept"
        static let xParseREST = "X-Parse-REST-API-Key"
        static let xParseAppID = "X-Parse-Application-Id"
        static let xsrfToken = "X-XSRF-TOKEN"
    }

    struct JSONHeaderValues {
        static let appJSON = "application/json"
        

        static let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    }

    struct JSONHeaderCommon {
        static let jsonHeaderCommonParse = [JSONHeaderField.xParseREST:JSONHeaderValues.restAPIKey,
                                            JSONHeaderField.xParseAppID:JSONHeaderValues.parseAppID]
    }
    
    enum MethodTypes: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    struct MapViewConstants {
        static let mapViewFineScale: Double = 50000
        static let mapViewLargeScale: Double = 500000
        static let defaultLatitude = 28.7041
        static let defaultLongitude = 77.1025
        static let defaultMediaURL = "https://www.google.com.au"
        static let pinReusableIdentifier = "locationPin"
        static let mapstring = ""
    }

}
