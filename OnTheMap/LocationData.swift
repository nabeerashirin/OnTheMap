//
// LocationData.swift
//  OnTheMap
//
//  Created by Nabeera Shirin on 20/08/18.
//  Copyright © 2018 dummy. All rights reserved.
//

import UIKit


class LocationData: NSObject {
    
    var studentLocations = [StudentLocation]()
    

    var myLocation: StudentLocation?

    var locationExists = false
    static let sharedInstance = LocationData()
    private override init() {}
}

