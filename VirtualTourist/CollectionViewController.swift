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

// Class created by losely following these tutorials http://www.ioscreator.com/tutorials/custom-collection-view-cell-tutorial-ios8-swift and https://www.hackingwithswift.com/read/10/3/data-sources-and-delegates-uicollectionviewdatasource

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollection: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    // MARK: Variables
    var droppedPin: Pin!
    
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
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewControllerCell
        return cell
    }
    
}