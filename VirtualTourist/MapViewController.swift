//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// -> http://www.myswiftjourney.me/2014/10/23/using-mapkit-mkmapview-how-to-create-a-annotation/
class MapViewController: UIViewController {
    
    // MARK: Structs
    
    struct MapRegionKeys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let LatitudeDelta = "latitudeDelta"
        static let LongitudeDelta = "longitudeDelta"
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var editModeBannerView: UIView!
    
    // MARK: Variables
    
    // Toggle between "edit" and "done" button as well as their functionalities
    var editModeEnabled = false
    
    // Add variable for storing pins restored from previous save
    // -> Udacity FavoriteActors example -> FavoriteActorsViewController.swift -> override func viewDidLoad()
    var restoredPins = [Pin]()
    
    // -> Udacity MemoryMap example
    var mapRegionFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    // Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    // -> Udacity FavoriteActors example
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate methods defined in class extension at bottom of this file
        mapView.delegate = self
        
        // Hide editModeBannerView
        editModeBannerView.hidden = true
        editModeBannerView.alpha = 0.0
        
        // Go back to map region saved during last time app was used
        // -> Udacity MemoryMap example -> ViewController.swift -> override func viewDidLoad()
        restoreMapRegion(false)
        
        // -> Udacity FavoriteActors example -> FavoriteActorsViewController.swift -> override func viewDidLoad()
        restoredPins = fetchAllPins()
        
        // For each pin in the restoredPins array, add an annotation to the annotations array
        // -> https://github.com/smspence/VirtualTourist
        if restoredPins.count > 0 {
            
            var annotations = [MKPointAnnotation]()
            
            for pin in restoredPins {
                let newAnnotation = MKPointAnnotation()
                newAnnotation.coordinate = pin.location
                annotations.append(newAnnotation)
            }
            
            mapView.addAnnotations(annotations)
        }
        
        // -> http://stackoverflow.com/questions/29720537/removing-pin-annotation-issue-in-mkmapview-swift
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    // MARK: Actions
    
    @IBAction func handleEditButtonTapped(sender: AnyObject) {
        
        editModeEnabled = !editModeEnabled
        
        if editModeEnabled {
            // "Edit" was pressed
            editModeStart()
        } else {
            // "Done" was pressed
            editModeEnd()
        }
    }
    
    // MARK: Functions
    
    // -> Udacity FavoriteActors Example -> FavoriteActorViewController.swift -> func fetchAllActors()
    func fetchAllPins() -> [Pin] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: Pin.Constants.EntityName)
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            
        } catch let error as NSError {
            
            print("Error in fetchAllPins(): \(error)")
            return [Pin]()
            
        }
    }
    
    func editModeStart() {
        
        editButton.title = "Done"
        editButton.style = UIBarButtonItemStyle.Done
        
        editModeBannerView.hidden = false
        UIView.animateWithDuration(0.5) {
            self.editModeBannerView.alpha = 1.0
        }
    }
    
    func editModeEnd() {
        
        editButton.title = "Edit"
        editButton.style = UIBarButtonItemStyle.Plain
        
        UIView.animateWithDuration(0.5, animations: {
            self.editModeBannerView.alpha = 0.0
            }) { (finished) -> Void in
                self.editModeBannerView.hidden = true
        }
    }
    
    // Function for handling long press by user
    // -> http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == .Began && !editModeEnabled {
            
            let touchCoordinatesXY : CGPoint = gestureRecognizer.locationInView(mapView)
            
            let latLonCoordinates = mapView.convertPoint(touchCoordinatesXY, toCoordinateFromView: mapView)
            
            print("x, y: \(touchCoordinatesXY)  lat, lon: (\(latLonCoordinates.latitude), \(latLonCoordinates.longitude))")
            
            addMapAnnotationAtLatLon(latLonCoordinates)
            addPinObjectAtLatLon(latLonCoordinates)
        }
    }
    
    // Add pin; called in handeLongPress()
    // -> Udacity FavoriteActors Example -> FavoriteActorViewController.swift -> func actorPicker()
    func addPinObjectAtLatLon(latLonPoint: CLLocationCoordinate2D) {
        
        // Create a new Pin using the shared context
        _ = Pin(dictionary: latLonPoint, context: sharedContext)
        
        // Save the shared context using the convenience method in the CoreDataStackManager
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Add annotation; called in handeLongPress()
    // -> http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching
    func addMapAnnotationAtLatLon(latLonPoint: CLLocationCoordinate2D) {
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = latLonPoint
        
        mapView.addAnnotation(newAnnotation)
    }
    
    // Function for returning pin with correct coordinates when dropped pin is clicked on
    // -> https://github.com/smspence/VirtualTourist
    func fetchPinForAnnotation(annotation: MKAnnotation) -> Pin? {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: Pin.Constants.EntityName)
        
        // Add format specifier %lf to search for double format
        // -> https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
        fetchRequest.predicate = NSPredicate(format: "latitude == %lf && longitude == %lf",
            annotation.coordinate.latitude, annotation.coordinate.longitude)
        
        let results: [AnyObject]?
        
        // Execute the Fetch Request
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Error in fetchAllPins(): \(error)")
            results = nil
        }
        
        var returnObject : Pin? = nil
        
        if let results = results as? [Pin] {
            
            if results.count > 0 {
                
                // Return first result at index 0
                returnObject = results[0]
                
                // Print error if more than one result fetched
                if results.count > 1 {
                    print("Error. Fetch for pin for annotation returned \(results.count) results instead of 1 result.")
                }
                
            } else {
                // Print error if no result is fetched
                print("Error. Fetch for pin for annotation returned 0 results.")
            }
        }
        
        return returnObject
    }
    
    // Function for saving map region where user has zoomed in
    // -> Udacity MemoryMap example
    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            MapRegionKeys.Latitude : mapView.region.center.latitude,
            MapRegionKeys.Longitude : mapView.region.center.longitude,
            MapRegionKeys.LatitudeDelta : mapView.region.span.latitudeDelta,
            MapRegionKeys.LongitudeDelta : mapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: mapRegionFilePath)
    }
    
    // Function for zooming to saved map region
    // -> Udacity MemoryMap example
    func restoreMapRegion(animated: Bool) {
        
        // If we can unarchive a dictionary, we will use it to set the map back to its previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(mapRegionFilePath) as? [String : AnyObject] {
            
            let latitude = regionDictionary[MapRegionKeys.Latitude] as! CLLocationDegrees
            let longitude = regionDictionary[MapRegionKeys.Longitude] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let latitudeDelta = regionDictionary[MapRegionKeys.LatitudeDelta] as! CLLocationDegrees
            let longitudeDelta = regionDictionary[MapRegionKeys.LongitudeDelta] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            print("Unarchived map region: lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            mapView.setRegion(savedRegion, animated: animated)
        }
    }
    
}
    
    /**
     *  This extension comforms to the MKMapViewDelegate protocol. This allows
     *  the view controller to be notified whenever the map region changes. So
     *  that it can save the new region.
     *  -> Udacity MemoryMap example
     */
    
    extension MapViewController : MKMapViewDelegate {
    
    // Save map region if map region was changed
    // -> Udacity MemoryMap example
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    // Function specifying what happens if user clicks on dropped pin
    // -> https://github.com/smspence/VirtualTourist
    func mapView(mapViefw: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if let pin = fetchPinForAnnotation(view.annotation!) {
            
            // If "edit" button was clicked...
            if editModeEnabled {
                
                // ...delete the pin
                pin.clearPhotos()
                sharedContext.deleteObject(pin)
                CoreDataStackManager.sharedInstance().saveContext()
                
                mapView.removeAnnotation(view.annotation!)
                
            // If "edit" button was not clicked...
            } else {
                
                // ...go to CollectionViewController
                let collectionViewController = self.storyboard!.instantiateViewControllerWithIdentifier("CollectionViewControllerId") as! CollectionViewController
                collectionViewController.pin = pin
                self.navigationController!.pushViewController(collectionViewController, animated: true)
            }
            
        } else {
            print("Error. Pin object associated with annotation not found.")
        }
        
        // Finally, deselect annotation
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
    
    // Dequeue annotation view
    // -> http://stackoverflow.com/questions/31297109/dequeuereusableannotationviewwithidentifier-in-swift
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        let pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) ??
            MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        return pinView
        
    }

}
