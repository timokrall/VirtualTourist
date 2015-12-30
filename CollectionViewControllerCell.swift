//
//  CollectionViewControllerCell.swift
//  VirtualTourist
//
//  Created by Timo Krall on 12/21/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit

class CollectionViewControllerCell: UICollectionViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageOverlay: UIView!

    // MARK: Variables
    
    // -> Udacity FavoriteActors Example
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    // MARK: Functions
    
    // Function for showing or hiding selectionOverlayView
    // Show if setOverlayHidden(false)
    // Hide if setOverlayHidden(true)
    func setOverlayHidden(state : Bool) {
        imageOverlay.hidden = state
    }
    
}
