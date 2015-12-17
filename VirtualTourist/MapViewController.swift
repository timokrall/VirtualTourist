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

class MapViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapEdit: UIBarButtonItem!
    
    // MARK: Variables
    var geoCoder = CLGeocoder()
    var location: CLLocation!
    var region: MKCoordinateRegion!
    var latitude: AnyObject?
    var longitude: AnyObject?
    var errorMsg: String = ""
    
    // MARK: Lifycycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Functions
    
    // MARK: Actions
    @IBAction func mapEditAction(sender: AnyObject) {
    }

}

