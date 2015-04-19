//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Vishnu on 14/04/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import Foundation
import MapKit

class Pin {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    var latitude: Double
    var longitude: Double
    var photos: [Photo] = [Photo]()
    
    init(dictionary: [String: AnyObject]) {
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
    }
    
}