//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
// -> https://github.com/smspence/VirtualTourist
    
    // MARK: Variables
    
    var pin: Pin!
    var selectedIndexPaths = Set<NSIndexPath>()
    
    var downloadsInProgress: Int = 0 {
        didSet {
            // Deactivate newCollectionButton while images downloading
            if downloadsInProgress == 0 {
                newCollectionButton.enabled = true
            } else {
                newCollectionButton.enabled = false
            }
        }
    }
    
    // Core Data Convenience. This will be useful for adding and saving objects.
    // -> Udacity FavoriteActors example
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    // MARK: Outlets
    
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var toolbarWithTrashButton: UIToolbar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var toolbarWithNewCollectionButton: UIToolbar!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        // Display location associated with pin selected by user in MapViewController
        setUpMapView()
        
        // Hide noImagesLabel by default
        // noImagesLabel will be displayed only if there are no images
        noImagesLabel.hidden = true
        
        // Hide toolbarWithTrashButton and show toolbarWithNewCollectionButton
        standardToolbars()
        
        // If there are no photos yet, download new photos
        if pin.photos.isEmpty {
            downloadPhotoUrls()
        }
    }
    
    // MARK: Actions
    
    // Action when trashButton tapped
    @IBAction func handleTrashButtonTapped(sender: AnyObject) {
        
        // Show alert to user when trash button is tapped
        let selectedCount = selectedIndexPaths.count
        let controller = UIAlertController()
        controller.title = "Are you sure you want to delete the selected photo"
        
        // Adjust title from singular to plural wording depending on number of photos to be deleted
        controller.title = controller.title! + ((selectedCount > 1) ? "s?" : "?")
        
        // Remind user how many photos are about to be deleted
        let deleteButtonTitle = (selectedCount > 1) ? "Delete \(selectedCount) Photos" : "Delete Photo"
        
        // Run doDelete() if user confirms
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: UIAlertActionStyle.Destructive) {
            action in self.doDelete()
        }
        
        // Allow user to cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // Display alert with functionality to delete and cancel depending on user response
        controller.addAction(deleteAction)
        controller.addAction(cancelAction)
        self.presentViewController(controller, animated: true, completion: nil)

    }
    
    // Action when newCollectionButton is tapped
    @IBAction func handleNewCollectionButtonTapped(sender: AnyObject) {
        print("newCollectionButton tapped")
        
        pin.clearPhotos()
        
        self.collectionView.reloadData()
        
        downloadPhotoUrls()
        
    }
    
    // MARK: Functions
    
    // Function called by doDelete() to delete selected items
    func updateModelAndDeleteItemsFromCollectionView(collectionView: UICollectionView, indexPathsToDelete: [NSIndexPath]) {
        
        for indexPath in indexPathsToDelete {
            
            let photo = pin.photos[indexPath.item]
            
            // Delete image file from image cache and documents directory
            photo.image = nil
            
            // Remove photo object from CoreData
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(photo)
            
            // Deselect deleted image
            // Deselecting avoids prompting the user to delete deleted images
            selectedIndexPaths.remove(indexPath)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        collectionView.deleteItemsAtIndexPaths(indexPathsToDelete)
        
    }
    
    // Function sorting array and deleting selected items
    func doDelete() {
        
        // Delete photos from photos array from highest to lowest index
        var sortedArray = Array(self.selectedIndexPaths)
        sortedArray.sortInPlace { (indexPath1 : NSIndexPath, indexPath2 : NSIndexPath) -> Bool in
            return indexPath1.item > indexPath2.item
        }
        
        updateModelAndDeleteItemsFromCollectionView(collectionView, indexPathsToDelete: sortedArray)
        
        // Refresh toolbars after deletion is completed to hide trash toolbar
        toggleToolbars()
    }
    
    // Function for downloading new photos
    func downloadPhotoUrls() {
        
        FlickrClient.sharedInstance().getPhotosAtLocation(pin.location.latitude, longitude: pin.location.longitude) { (photoUrls: [String]) in
            
            self.noImagesLabel.hidden = (photoUrls.count > 0)
            
            for url in photoUrls {
                
                let photo = Photo(dictionary: url, context: self.sharedContext)
                
                // Establish the relationship between photo and pin in CoreData
                photo.pin = self.pin
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            self.collectionView.reloadData()
        }
    }
    
    // Function for displaying the location associated with the pin that was selected by the user in MapViewController
    func setUpMapView() {
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = pin.location
        mapView.addAnnotation(newAnnotation)
        mapView.setRegion(MKCoordinateRegion(center: pin.location, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075)), animated: false)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos.count
    }
    
    // -> http://stackoverflow.com/questions/27374755/how-to-show-an-uiactivityindicator-in-uicollectionview-customcell-untill-the-ima
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewControllerCellReuseId", forIndexPath: indexPath) as! CollectionViewControllerCell
        
        // placeholderImage is edited open source icon
        // -> http://uxrepo.com/icon/icon_loading-by-elegant
        var image = UIImage(named: "placeholderImage")
        
        let photo = pin.photos[indexPath.item]
        
        if photo.photoURL == nil || photo.photoURL == "" {
            print("Error. Photo has no Flickr URL, and cannot be downloaded.")
        } else if photo.image != nil {
            image = photo.image
        } else {
            
            // Download image from Flickr
            
            downloadsInProgress++
            
            let task = FlickrClient.sharedInstance().taskForFile(photo.photoURL!) { (downloadedData, error) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.downloadsInProgress--
                }
                
                if let error = error {
                    print("Error returned when trying to download image from Flickr: \(error)")
                }
                
                if let imageData = downloadedData {
                    
                    let downloadedImage = UIImage(data: imageData)
                    
                    // Ensure UI updates and CoreData updates are made on main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        cell.imageView.image = downloadedImage
                        
                        // Ensure image is associated with Photo object in CoreData
                        photo.image = downloadedImage
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                }
            }
            
            cell.taskToCancelifCellIsReused = task
        }
        
        cell.imageView.image = image

        if selectedIndexPaths.contains(indexPath) {
            cell.setOverlayHidden(false)
        } else {
            cell.setOverlayHidden(true)
        }
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Show view that highlights a selected cell
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CollectionViewControllerCell {
            cell.setOverlayHidden(false)
        }
        
        // Select cell for deletion
        selectedIndexPaths.insert(indexPath)
        toggleToolbars()
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Hide view that highlights a selected cell
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CollectionViewControllerCell {
            cell.setOverlayHidden(true)
        }

        // Deselect cell
        selectedIndexPaths.remove(indexPath)
        toggleToolbars()
        
    }
    
    // Function for showing appropriate toolbar depending on how many pictures are selected
    func toggleToolbars() {
        toolbarWithTrashButton.hidden = (self.selectedIndexPaths.count == 0)
        toolbarWithNewCollectionButton.hidden = (self.selectedIndexPaths.count > 0)
    }
    
    // Function for hiding trash button and showing new collection button
    func standardToolbars() {
        toolbarWithTrashButton.hidden = true
        toolbarWithNewCollectionButton.hidden = false
    }
    
}
