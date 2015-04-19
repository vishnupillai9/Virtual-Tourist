//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Vishnu on 16/04/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import Foundation
import MapKit

extension FlickrClient {
    
    func getImageFromFlickr(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandler: (success: Bool, dictionary: [[String: AnyObject]]?, errorString: String?) -> Void) {
        
        var boundedBox: String {
            return "\(longitude - 1.0),\(latitude - 1.0),\(longitude + 1.0),\(latitude + 1.0)"
        }
        
        let methodArguments: [String: AnyObject] = [
            ParameterKeys.Method: Methods.PhotosSearch,
            ParameterKeys.ApiKey: Constants.ApiKey,
            ParameterKeys.BBox: boundedBox,
            ParameterKeys.SafeSearch: Constants.SafeSearch,
            ParameterKeys.Extras: Constants.Extras,
            ParameterKeys.Format: Constants.Format,
            ParameterKeys.NoJSONCallBack: Constants.NoJSONCallBack
        ]
        
        let task = taskForGETMethod(methodArguments) { (JSONResult, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, dictionary: nil, errorString: "Could not complete the request \(error)")
            } else {
                if let photosDictionary = JSONResult.valueForKey(JSONResponseKeys.Photos) as? [String: AnyObject] {
                    if let photos = photosDictionary[JSONResponseKeys.Photo] as? [[String: AnyObject]] {
                        var resultDictionary = [[String: AnyObject]]()
                        do {
                            let photo = photos[self.count]
                            resultDictionary.append(photo)
                            self.count = self.count + 1
                        } while (self.count % 12 != 0)
                        
                        completionHandler(success: true, dictionary: resultDictionary, errorString: nil)
                        
                    }
                } else {
                    completionHandler(success: false, dictionary: nil, errorString: "Could not complete the request \(error)")
                }
            }
        }
    }

    
}