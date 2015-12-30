//
//  WebHelper.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit

class WebHelper : NSObject {
    
    // Given a dictionary of parameters, convert to a string for a url
    // -> Udacity FlickFinder example -> ViewController.swift -> escapedParameters()
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // Show network activity indicator
    class func showNetworkActivityIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    // Hide network activity indicator
    class func hideNetworkActivityIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // Generate alert message
    class func displayAlertMessage(message: String, viewController: UIViewController) {
        let controller = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)
        
        controller.addAction(okAction)
        viewController.presentViewController(controller, animated: true, completion: nil)
    }
    
}
