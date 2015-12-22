//
//  Photo.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import CoreData
import UIKit
import Foundation

class Photo: NSManagedObject {
    
    @NSManaged var photoURL: String
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageFilePath: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        self.photoURL = imageFilePath as String
        
    }
    
    
}