//
//  Pin.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

// Class fixed after looking up Abdallah ElMenoufy

import CoreData
import MapKit

class Pin: NSManagedObject {

    // MARK: Variables
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var numberOfPagesReturned: NSNumber?
    @NSManaged var photos: NSMutableOrderedSet
    
    var coordinate: CLLocationCoordinate2D {
    
        set {
         
            latitude = newValue.latitude
            longitude = newValue.longitude
        
        }

        get {
        
            return CLLocationCoordinate2DMake(latitude, longitude)
        
        }
    
    
    }
    
    // MARK: Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        photos = NSMutableOrderedSet()
        
    }
    

}