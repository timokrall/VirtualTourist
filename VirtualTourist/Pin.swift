//
//  Pin.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import MapKit
import CoreData

@objc(Pin)

// --> Udacity FavoriteActors example
class Pin : NSManagedObject {
    
    // Declare constant for "Pin"
    // -> https://github.com/smspence/VirtualTourist
    struct Constants {
        static let EntityName = "Pin"
    }
    
    // Declare simple properties of Pin class
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged private var latitude : Double
    @NSManaged private var longitude : Double
    @NSManaged var photos : [Photo]
    
    // Standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
     * Two argument Init method:
     *  - insert the new Pin into a Core Data Managed Object Context
     *  - initialize the Pin's properties from a dictionary
     */
    
    init(dictionary: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Pin" type
        // This is an object that contains the information from the VirtualTourist.xcdatamodeld file
        let entity =  NSEntityDescription.entityForName(Pin.Constants.EntityName, inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Pin class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the dictionary
        latitude = dictionary.latitude
        longitude = dictionary.longitude
    }
    
    var location : CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    // Function for removing image from image cache, documents directory, and core data
    // -> https://github.com/smspence/VirtualTourist
    func clearPhotos() {
        
        for photo in self.photos {
            photo.image = nil
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(photo)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
}
