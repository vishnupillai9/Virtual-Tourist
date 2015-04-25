//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Vishnu on 16/04/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

extension FlickrClient {
    
    struct Constants {
        static let ApiKey = "2e0d17f253d429e80aa94a9311231956"
        static let FlickrBaseURL = "https://api.flickr.com/services/rest/"
        static let SafeSearch = "1"
        static let Extras = "url_m"
        static let Format = "json"
        static let NoJSONCallBack = "1"
    }
    
    struct Methods {
        static let PhotosSearch = "flickr.photos.search"
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let BBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallBack = "nojsoncallback"
    }
    
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let ID = "id"
        static let Title = "title"
        static let URL = "url_m"
    }
    
}