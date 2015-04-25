//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Vishnu on 19/04/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    //MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        
        let manager = NSFileManager.defaultManager()
        let documentsDirectoryURL = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let url = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return url.path!
        
    }
    
    //MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        //If identifier is nil or empty, return
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        //Get path for identifier
        let path = pathForIdentifier(identifier!)
        
        var data: NSData?
        
        //Look for image in memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        //Look for image in hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    
    }
    
    //MARK: - Saving images
    
    func storeImage(image: UIImage?, identifier: String) {
        let path = pathForIdentifier(identifier)
        
        //If the image is nil, remove images from cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
            return
        }
        
        //Else keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        //Change image representation to PNG and save it to Documents Directory
        let data = UIImagePNGRepresentation(image!)
        data.writeToFile(path, atomically: true)
    }
    
    //MARK: - Clearing images from cache
    
    func clearCache() {
        inMemoryCache.removeAllObjects()
    }
    
    func clearImage(id: String) {
        inMemoryCache.removeObjectForKey(id)
        let path = pathForIdentifier(id)
        println("Image cleared at path: \(path)")
        NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
    }
    
    
    
}