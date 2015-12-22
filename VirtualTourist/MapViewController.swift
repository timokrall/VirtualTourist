//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/17/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

/**
* Five steps to using Core Data to persist MasterDetail:
*
* 1. Add a convenience method that find the shared context
* 2. Add fetchAllPins()
* 3. Invoke fetchAllPins in viewDidLoad()
* 4. Create a Pin object in insertNewObject()
* 5. Save the context in insertNewObject()
*
*/

import UIKit
import Foundation
import MapKit
import CoreData
import CoreLocation

// Class created losely following tutorial http://www.myswiftjourney.me/2014/10/23/using-mapkit-mkmapview-how-to-create-a-annotation/

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapEdit: UIBarButtonItem!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var mapPin: UILongPressGestureRecognizer!
    
    // MARK: Variables
    var editButton: UIBarButtonItem?
    var annotation = MKPointAnnotation()
    var pins = [Pin]()
    
    // Step 1: Add a "sharedContext" convenience property
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    // MARK: Lifycycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Step 3: Initialize the pins array with the results of the fetchAllPins() method
        pins = fetchAllPins()
        
        // Hide bottomLabel before edit button is pressed
        bottomLabel.hidden = true
        
        // Variable required for recognizing long press and starting handeLongPress() after long press is recognized
        // Variable created after reading stackoverflow post http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching
        
        // Variable required for recognizing tap and starting removeAnnotation() after tap is recognized
        // Variable created after reading stackoverflow post http://stackoverflow.com/questions/29720537/removing-pin-annotation-issue-in-mkmapview-swift
        
        // Connect edit button to mapEditPressed function
        editButton = editButtonItem()
        navigationItem.rightBarButtonItem = editButton
        editButton?.action = "mapEditPressed"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Functions
    
    // Step 2: Add a fetchAllPins() method
    func fetchAllPins() -> [Pin] {
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: sharedContext)
        var error: NSError? = nil
        
        fetchRequest.entity = entity
        
        var results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            results = nil
        }
        
        if let error = error {
            // TODO: display error message to user.
            print("Error fetching events:\(error)")
            return [Pin]()
        }
        
        return results as! [Pin]
    }
    
    func insertNewObject(sender: AnyObject) {
    
        // Step 4: Create a Pin object (and append it to the pins array.)
        
        let newPin = Pin(context: sharedContext)
        
        pins.append(newPin)
        
        // Step 5: Save the context (and check for an error.)
        
        var error: NSError?
        
        do {
            try sharedContext.save()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
        
            print("Error saving context: \(error)")
        
        }
        
        // TODO: verify this is the correct equivalent to "tableView.reloadData()"
        mapView.reloadInputViews()

    
    }

    // Function for dropping pin to map after long press
    // Function created after reading stackoverflow post http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching

    
    // Function for removing pin from map after tap
    // Function created after reading stackoverflow post http://stackoverflow.com/questions/29720537/removing-pin-annotation-issue-in-mkmapview-swift
    

    // Function for displaying the bottom label when edit button is pressed
    
    func mapEditPressed () {
    
        // Button label is shown when "Edit" is pressed
        // Adjust mapView to account for size of added bottom label
        // Change text to "Done"
        if editButtonItem().title == "Edit" {
        
            bottomLabel.hidden = false
            editButtonItem().title = "Done"
            mapView.frame.origin.y -= bottomLabel.frame.height
        
        // Button label is hidden when "Done" is pressed
        // Adjust mapView to account for size of removed bottom label
        // Change back to "Edit"
        } else if editButtonItem().title == "Done" {
        
            bottomLabel.hidden = true
            editButtonItem().title = "Edit"
            mapView.frame.origin.y += bottomLabel.frame.height
        
        }
    
    }
    
    // MARK: Actions
    @IBAction func mapEditAction(sender: AnyObject) {
        
    }

}

