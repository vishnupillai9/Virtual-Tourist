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

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var pin: Pin!
    var currentIndex: NSIndexPath?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if pin.photos.isEmpty {
            FlickrClient.sharedInstance().count = 0
            getImage()
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        self.newCollectionButton.enabled = false
        
        setLocation(pin.latitude, longitude: pin.longitude)
    
    }
    
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
                
                var photos = photosDictionary.map() { (dictionary: [String: AnyObject]) -> Photo in
                    let photo = Photo(dictionary: dictionary)
                    
                    self.pin.photos.append(photo)
                    
                    return photo
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView.reloadData()
                }
                
            } else {
                //Alert view to inform the user getting images failed
                var alert = UIAlertController(title: "Failed to get images", message: "Fetching images from Flickr failed", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pin.photos.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = pin.photos[indexPath.row]
        let CellIdentifier = "PhotoCell"
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        if let localImage = photo.image {
            //If image exists in cache, set the image
            cell.cellImage.image = localImage
        } else {
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            
            //Else download the image
            let task = FlickrClient.sharedInstance().taskForImage(photo.photoURL, completionHandler: { (imageData, error) -> Void in
                if let data = imageData {
                    dispatch_async(dispatch_get_main_queue()) {
                        let image = UIImage(data: data)
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.hidden = true
                        //Update the model, so that image gets cached
                        photo.image = image
                        cell.cellImage.image = image
                        
                        //TODO: Place this elsewhere
                        self.newCollectionButton.enabled = true
                    }
                }
            })
            
        }

        return cell
    }
    
    
    //Changing the size of the cell depending on the width of the device
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let imageDimension = self.view.frame.size.width / 3.33
        return CGSizeMake(imageDimension, imageDimension)
        
    }
    
    //Setting the left and right inset for cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let leftRightInset = self.view.frame.size.width / 57.0
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        currentIndex = indexPath
        var alertControllerForDeletingPhoto: UIAlertController
        
        alertControllerForDeletingPhoto = UIAlertController(title: "This photo will be deleted from the album.", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertControllerForDeletingPhoto.addAction(UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Destructive, handler: deletePhoto))
        
        alertControllerForDeletingPhoto.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertControllerForDeletingPhoto, animated: true, completion: nil)
        
    }
    
    func deletePhoto(sender: UIAlertAction!) -> Void {
    
        let index = currentIndex?.row
        self.pin.photos.removeAtIndex(index!)
        
        self.collectionView.reloadData()
    }
    
    @IBAction func newCollectionButtonTouch(sender: UIBarButtonItem) {
        self.pin.photos = [Photo]()
        getImage()
    }
    

}
