//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/17/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation

class CollectionViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollection: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Variables
    
    // MARK: Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func newCollectionAction(sender: AnyObject) {
    }
    
    // MARK: Functions

}
