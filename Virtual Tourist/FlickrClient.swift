//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Vishnu on 16/04/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    var session: NSURLSession
    var count = 0

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForGETMethod (methodArguments: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //1. Parameters
        
        //2. Build url
        let urlString = Constants.FlickrBaseURL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        
        //3. Configure request
        let request = NSURLRequest(URL: url)
        
        //4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                //5/6. Parse and use data
                FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        //7. Start the request
        task.resume()
        
        return task
    }
    
    func taskForImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        
        //1. No parameters
        
        //2. Build url
        let url = NSURL(string: filePath)!
        
        //3. Configure request
        let request = NSURLRequest(URL: url)
        
        //4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(imageData: nil, error: error)
            } else {
                //5/6. Parse and use the data
                completionHandler(imageData: data, error: nil)
            }
        }
        
        //7. Start the request
        task.resume()
        
        return task
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
        
    }
    
    
    // Helper function: Given a dictionary of parameters, convert to a string for a url
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            //Make sure that it is a string value
            let stringValue = "\(value)"
            
            //Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            //FIX: Replace spaces with '+' */
            let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            //Append it
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
}