//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Vishnu on 12/04/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var pin: Pin!
    var currentIndex: NSIndexPath?
    var insertionsAtIndexPath = [NSIndexPath]()
    var deletionsAtIndexPath = [NSIndexPath]()
    var sectionsToInsert: NSIndexSet?
    var sectionsToDelete: NSIndexSet?
    var numberOfImagesLoaded = 0
    var changes = [(NSFetchedResultsChangeType, NSIndexPath)]()
    
    override func didReceiveMemoryWarning() {
        FlickrClient.Caches.imageCache.clearCache()
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        
        setLocation(pin.latitude, longitude: pin.longitude)
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if pin.photos.isEmpty {
            FlickrClient.sharedInstance().count = 0
            self.newCollectionButton.enabled = false
            getImage()
        }
    }
    
    //MARK: - Core Data Convenience
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoTitle", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    //MARK: - Helper 
    
    func setLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        
        mapView.addAnnotation(newAnnotation)
        mapView.setRegion(region, animated: true)
    }
    
    func getImage() {
        let latitude = pin.latitude
        let longitude = pin.longitude
        
        FlickrClient.sharedInstance().getImageFromFlickr(latitude, longitude: longitude) { (success, dictionary, errorString) -> Void in
            if success {
                
                let photosDictionary = dictionary!
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var photos = photosDictionary.map() { (dictionary: [String: AnyObject]) -> Photo in
                        let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                        photo.pin = self.pin
                        CoreDataStackManager.sharedInstance().saveContext()
                        return photo
                    }
                })
                
            } else {
                //Alert view to inform the user getting images failed
                var alert = UIAlertController(title: "Failed to get images", message: "Fetching images from Flickr failed", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - Collection View
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let CellIdentifier = "PhotoCell"
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        configureCell(cell, photo: photo, indexPath: indexPath)

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentIndex = indexPath
        var alertControllerForDeletingPhoto: UIAlertController
        
        alertControllerForDeletingPhoto = UIAlertController(title: "This photo will be deleted from the album.", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertControllerForDeletingPhoto.addAction(UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Destructive, handler: deletePhoto))
        alertControllerForDeletingPhoto.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertControllerForDeletingPhoto, animated: true, completion: nil)
    }
    
    //MARK: - Collection View Delegate Flow Layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //Changing the size of the cell depending on the width of the device
        let imageDimension = self.view.frame.size.width / 3.33
        return CGSizeMake(imageDimension, imageDimension)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        //Setting the left and right inset for cells
        let leftRightInset = self.view.frame.size.width / 57.0
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
    
    //MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        changes = []
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            changes.append((.Insert, newIndexPath!))
        case .Delete:
            changes.append((.Delete, indexPath!))
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({ () -> Void in
            for (type, index) in self.changes {
                switch type {
                case .Insert:
                    self.collectionView.insertItemsAtIndexPaths([index])
                case .Delete:
                    self.collectionView.deleteItemsAtIndexPaths([index])
                default:
                    continue
                }
            }
            }, completion: { completed -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //self.newCollectionButton.enabled = true
                })
        })
    }
    
    //MARK: - Actions
    
    func deletePhoto(sender: UIAlertAction!) -> Void {
        let index = currentIndex
        
        let photo = self.fetchedResultsController.objectAtIndexPath(index!) as! Photo
        //Clear the image from cache
        FlickrClient.Caches.imageCache.clearImage(photo.photoID)
        //Delete the image from album
        self.sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
        
        self.collectionView.reloadData()
    }
    
    @IBAction func newCollectionButtonTouch(sender: UIBarButtonItem) {
        self.numberOfImagesLoaded = 0
        self.newCollectionButton.enabled = false
        if let photos = self.fetchedResultsController.fetchedObjects as? [Photo] {
            for photo in photos {
                //Clear all images from cache
                FlickrClient.Caches.imageCache.clearImage(photo.photoID)
                //Delete all images from album
                self.sharedContext.deleteObject(photo)
            }
        }
        //Get new set of images for album
        getImage()
    }
    
    //MARK: - Configure Cell
    
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo, indexPath: NSIndexPath) {
        var image = UIImage()
        
        if let localImage = photo.image {
            image = localImage
        } else {
            //Else download the image
            let task = FlickrClient.sharedInstance().taskForImage(photo.photoURL, completionHandler: { (imageData, error) -> Void in
                if let data = imageData {
                    //cell.activityIndicator.hidden = false
                    //cell.activityIndicator.startAnimating()
                    
                    //Create the image
                    let image = UIImage(data: data)
                        
                    //Update the model, so that image gets cached
                    photo.image = image
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        cell.activityIndicator.stopAnimating()
                        //cell.activityIndicator.hidden = true
                        cell.cellImage.image = image
                        self.numberOfImagesLoaded = self.numberOfImagesLoaded + 1
                        
                        var numberOfImages = (self.fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo).numberOfObjects
                        
                        if self.numberOfImagesLoaded == numberOfImages {
                            self.newCollectionButton.enabled = true
                        }
                    }
                }
            })
            
        }
        
        cell.cellImage.image = image
        self.collectionView.reloadItemsAtIndexPaths([indexPath])
    }
}
