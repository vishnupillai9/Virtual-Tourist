//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Vishnu on 18/04/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import Foundation
import UIKit

class Photo {
    
    struct Keys {
        static let PhotoID = "id"
        static let PhotoTitle = "title"
        static let PhotoURL = "url_m"
    }
    
    var photoID: String
    var photoTitle: String
    var photoURL: String
    
    init(dictionary: [String: AnyObject]) {
        
        photoID = dictionary[Keys.PhotoID] as! String
        photoTitle = dictionary[Keys.PhotoTitle] as! String
        photoURL = dictionary[Keys.PhotoURL] as! String
    }
    
    var image: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(photoURL)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(image, identifier: photoURL)
        }
    }
    
}