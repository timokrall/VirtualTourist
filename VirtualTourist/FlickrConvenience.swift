//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import Foundation

// -> http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // Empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

extension FlickrClient {
    
    // -> https://github.com/smspence/VirtualTourist
    private func getJsonForPhotosAtLocation(latitude: Double, longitude: Double, completionHandler: (photoUrls: [String], success: Bool) -> Void) {
        
        let deltaDegrees = 0.25
        
        // -> https://www.flickr.com/services/api/flickr.photos.search.html -> bbox
        let bboxString = "\(longitude-deltaDegrees),\(latitude-deltaDegrees),\(longitude+deltaDegrees),\(latitude+deltaDegrees)"
        
        let parameters = [
            "method": Constants.Method,
            "api_key": Constants.ApiKey,
            "extras": "url_m",
            "safe_search": "3",
            "format": "json",
            "nojsoncallback": "1",
            "bbox": bboxString
        ]
        
        taskForResource(parameters) { (JSONResult, error) in
            
            var success = false
            var photoUrls : [String] = [String]()
            
            if let error = error {
                print("getJsonForPhotos download error: \(error)")
            } else {
                
                if let photosDictionary = JSONResult["photos"] as? [String : AnyObject] {
                    
                    // Determine number of photos
                    let numPhotos : Int
                    if let totalPhotosVal = photosDictionary["total"] as? String {
                        numPhotos = (totalPhotosVal as NSString).integerValue
                    } else {
                        numPhotos = 0
                    }
                    
                    print("Found \(numPhotos) photos")
                    
                    if numPhotos > 0 {
                        
                        // Get URLs for photos
                        if let photosArray = photosDictionary["photo"] as? [[String : AnyObject]] {
                            
                            print("photosDictionary contains \(photosArray.count) photos")
                            
                            // Return array of up to 24 randomly selected photo URLs
                            let maxPhotosToReturn = 24
                            let numPhotosToReturn = min(maxPhotosToReturn, photosArray.count)
                            
                            let randomArrayIndices = self.getRandomIndicesWithArraySize(photosArray.count)
                            
                            for i in 0 ..< numPhotosToReturn {
                                
                                let photoMetaData = photosArray[ randomArrayIndices[i] ]
                                
                                if let photoUrlString = photoMetaData["url_m"] as? String {
                                    
                                    photoUrls.append(photoUrlString)
                                    
                                }
                            }
                            
                        }
                    }
                    
                    success = true
                    
                } else {
                    print("Error. Could not find \"photos\" object in JSON result.")
                }
            }
            
            // call completion handler on the main thread
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(photoUrls: photoUrls, success: success)
            }
        }
        
    }
    
    private func getRandomIndicesWithArraySize(let arraySize: Int) -> [Int] {
        
        var arrayOfIndices : [Int] = [Int]()
        arrayOfIndices.reserveCapacity(arraySize)
        
        for i in 0 ..< arraySize {
            arrayOfIndices.append(i)
        }
        
        arrayOfIndices.shuffleInPlace()
        
        return arrayOfIndices
    }
    
    func getPhotosAtLocation(latitude: Double, longitude: Double, completionHandler: (photoUrls: [String]) -> Void) {
        
        getJsonForPhotosAtLocation(latitude, longitude: longitude) { (photoUrls: [String], success: Bool) in
            
            if success {
                print("Successfully completed getPhotosAtLocation.")
            } else {
                print("Unsuccessful execution of getPhotosAtLocation.")
            }
            
            completionHandler(photoUrls: photoUrls)
        }
    }
    
}
