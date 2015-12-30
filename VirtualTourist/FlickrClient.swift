//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
// -> Udacity FavoriteActors example -> TheMovieDB.swift
    
    // Used by parseJSONWithCompletionHandler() and taskForResource()
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    // Shared session
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // Shared instance
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // All purpose task method for data
    // -> Udacity FavoriteActors example -> TheMovieDB.swift -> taskForResource()
    func taskForResource(parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        // Set parameters, build URL, and configure request
        let urlString = Constants.BaseURLSecure + WebHelper.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // Make request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if downloadError != nil {
                // Handle error
                completionHandler(result: nil, error: downloadError)
            } else {
                // Parse and use data
                print("taskForResource's completionHandler is invoked.")
                FlickrClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        // Start request
        task.resume()
        return task
    }
    
    // Parse JSON, return usuable foundation object
    // -> Udacity FavoriteActors example -> TheMovieDB.swift -> parseJSONWithCompletionHandler()
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            print("parseJSONWithCompletionHandler is invoked.")
            completionHandler(result: parsedResult, error: nil)
        }
    }

    // -> Udacity FavoriteActors example -> TheMovieDB.swift -> taskForImageWithSize()
    func taskForFile(urlString: String, completionHandler: (downloadedData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: urlString)!
        
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(downloadedData: nil, error: downloadError)
            } else {
                completionHandler(downloadedData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
}
