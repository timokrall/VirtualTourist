//
//  Photo.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

// --> Udacity FavoriteActors example
class Photo : NSManagedObject {
    
    // Declare constant for "Photo"
    // -> https://github.com/smspence/VirtualTourist
    struct Constants {
        static let EntityName = "Photo"
    }
    
    // Declare simple properties of Photo class
    struct Keys {
        static let PhotoURL = "photoURL"
        static let ImagePath = "imagePath"
        static let Pin = "pin"
    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var photoURL : String?
    @NSManaged private var imagePath : String?
    @NSManaged var pin : Pin?
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
     * Two argument Init method:
     *  - insert the new Photo into a Core Data Managed Object Context
     *  - initialize the Photo's properties from a dictionary
     */
    
    init(dictionary: String, context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Photo" type
        // This is an object that contains the information from the VirtualTourist.xcdatamodeld file
        let entity =  NSEntityDescription.entityForName(Photo.Constants.EntityName, inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Photo class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the dictionary
        photoURL = dictionary
        imagePath = (dictionary as NSString).lastPathComponent
    }
    
    // Set and get methods
    // -> https://github.com/smspence/VirtualTourist
    var image: UIImage? {
        
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            if let imagePath = self.imagePath where imagePath.characters.count > 0 {
                FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath)
            }
        }
    }
    
}
