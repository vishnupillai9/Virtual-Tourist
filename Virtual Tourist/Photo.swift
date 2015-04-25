//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Vishnu on 18/04/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    
    struct Keys {
        static let PhotoID = "id"
        static let PhotoTitle = "title"
        static let PhotoURL = "url_m"
    }
    
    @NSManaged var photoID: String
    @NSManaged var photoTitle: String
    @NSManaged var photoURL: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    
        photoID = dictionary[Keys.PhotoID] as! String
        photoTitle = dictionary[Keys.PhotoTitle] as! String
        photoURL = dictionary[Keys.PhotoURL] as! String
    }
    
    var image: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(photoID)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(image, identifier: photoID)
        }
    }
    
}