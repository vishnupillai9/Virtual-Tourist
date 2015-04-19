//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Vishnu on 08/04/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var pins = [Pin]()
    
    var filePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    func fetchAllPins() -> [Pin] {
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        
        if error != nil {
            println("Error in fetchAllPins(): \(error)")
            return [Pin]()
        }
        
        return results as! [Pin]
    }
    
    func addPinsToMap() {
        for pin in pins {
            var dropPin = MKPointAnnotation()
            dropPin.coordinate.latitude = pin.latitude
            dropPin.coordinate.longitude = pin.longitude
            mapView.addAnnotation(dropPin)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        //Restoring the state of the map
        restoreMapRegion(true)
        
        //Fetching all pins
        pins = fetchAllPins()
        
        //Add them to the map
        addPinsToMap()
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongTapMap:")
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.numberOfTapsRequired = 0
        longPressGestureRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.navigationBarHidden = true
    }
    
    //Persist center and zoom level of map
    func saveMapRegion() {
        //The center and span is saved in a dictionary and archived using NSKeyedArchiver and stored in the Documents Directory of the app
        let dictionary = [
            "latitude": mapView.region.center.latitude,
            "longitude": mapView.region.center.longitude,
            "latitudeDelta": mapView.region.span.latitudeDelta,
            "longitudeDelta": mapView.region.span.longitudeDelta
        ]
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        //Save the map region whenever region changes
        saveMapRegion()
    }
    
    func restoreMapRegion(animated: Bool) {
        //Unarchiving the center and span data
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String: AnyObject] {
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let latitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let longitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            //Set the map to the saved region
            mapView.setRegion(savedRegion, animated: animated)
        }
    }
    
    func didLongTapMap(gestureRecognizer: UIGestureRecognizer) {
        // Get the spot that was tapped.
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        println(tapPoint)
        println(touchMapCoordinate)
        
        if gestureRecognizer.state != .Ended {
            return
        }
        
        let dictionary: [String: AnyObject] = [
            Pin.Keys.Latitude: touchMapCoordinate.latitude,
            Pin.Keys.Longitude: touchMapCoordinate.longitude
        ]
        
        let pinToBeAdded = Pin(dictionary: dictionary, context: self.sharedContext)
        
        pins.append(pinToBeAdded)
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        var dropPin = MKPointAnnotation()
        dropPin.coordinate.latitude = pinToBeAdded.latitude
        dropPin.coordinate.longitude = pinToBeAdded.longitude
        mapView.addAnnotation(dropPin)
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        var newAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin1")
        //newAnnotation.pinColor = MKPinAnnotationColor.Purple
        newAnnotation.animatesDrop = true
        
        return newAnnotation
        
    }
    
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        
        let pinCount = pins.count
        var i = 0
        var index: Int?
        
        for i = 0; i < pinCount; i++ {
            if view.annotation.coordinate.latitude == pins[i].latitude && view.annotation.coordinate.longitude == pins[i].longitude {
                index = i
            }
        }
        
        controller.pin = pins[index!]
        
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

