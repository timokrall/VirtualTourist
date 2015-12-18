//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/17/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation

// Class created losely following tutorial http://www.myswiftjourney.me/2014/10/23/using-mapkit-mkmapview-how-to-create-a-annotation/

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapEdit: UIBarButtonItem!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var mapPin: UILongPressGestureRecognizer!
    
    // MARK: Variables
    var editButton: UIBarButtonItem?

    // MARK: Lifycycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide bottomLabel before edit button is pressed
        bottomLabel.hidden = true
        
        // Variable required for recognizing long press and starting handeLongPress() after long press is recognized
        // Variable created after reading stackoverflow post http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching
        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        
        // Connect edit button to mapEditPressed function
        editButton = editButtonItem()
        navigationItem.rightBarButtonItem = editButton
        editButton?.action = "mapEditPressed"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Functions
    
    // Function for dropping pin to map after long press
    // Function created after reading stackoverflow post http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching
    
    func handleLongPress(gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .Began { return }
        
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        mapView.addAnnotation(annotation)
    }
    
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

