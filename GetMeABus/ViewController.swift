//
//  ViewController.swift
//  GetMeABus
//
//  Created by Bilawal Hameed on 01/08/2015.
//  Copyright (c) 2015 SyeefOrg. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import KNSemiModalViewController

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var MapView: MKMapView!
    private var locationManager : CLLocationManager!
    private var currentLocation : CLLocationCoordinate2D!
    private var initLocation : Bool = false
    private var annotations : [MKAnnotation] = [MKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        locationManager.startUpdatingLocation()
        
        MapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location : CLLocation = locations[0] as! CLLocation
        currentLocation = location.coordinate
        
        if initLocation == false {
            initLocation = true
            MapView.showsUserLocation = true
            centerMap()
        }
    }
    
    @IBAction func onButtonPress(sender: AnyObject) {
        centerMap()
    }
    
    func centerMap() {
        var mapRegion : MKCoordinateRegion!
        mapRegion = MKCoordinateRegion()
        mapRegion.center = currentLocation
        mapRegion.span.latitudeDelta = 0.01
        mapRegion.span.longitudeDelta = 0.01
        
        MapView.setRegion(mapRegion, animated: true)
        
        getStops()
    }
    
    func getStops() {
        var url = "http://transportapi.com/v3/uk/bus/stops/near.json?lat=\(currentLocation.latitude)&lon=\(currentLocation.longitude)&api_key=e2c96777c715a5d317c9d2016fdf5284&app_id=b4d09e5d"
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        self.MapView.removeAnnotations(self.annotations)
        
        Alamofire
          .request(.GET, url, parameters: nil)
          .responseSwiftyJSON({ (_, _, data : JSON, _) in
            
            self.annotations = []
            
            for (stop: JSON) in data["stops"].arrayValue {
                var annotation = GMABPointAnnotation()
                annotation.title = stop["name"].stringValue
                annotation.subtitle = stop["indicator"].stringValue
                annotation.stopName = stop["name"].stringValue
                annotation.atcoCode = stop["atcocode"].stringValue
                annotation.coordinate = CLLocationCoordinate2D(latitude: stop["latitude"].doubleValue, longitude: stop["longitude"].doubleValue)
                self.annotations.append(annotation)
            }
            
            self.MapView.addAnnotations(self.annotations)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          })
    }
    
    // Here we add disclosure button inside annotation window
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        var button = UIButton()
        button.setImage(UIImage(named: "clock"), forState: UIControlState.Normal)
        button.frame = CGRectMake(0, 0, 40, 40)
        
        pinView?.rightCalloutAccessoryView = button
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let stopName = (annotationView.annotation as! GMABPointAnnotation).stopName
        let atcoCode = (annotationView.annotation as! GMABPointAnnotation).atcoCode
        
        let timetableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("timetable") as! TimetableController
        timetableViewController.stopName = stopName
        timetableViewController.atcoCode = atcoCode
        timetableViewController.view.frame = CGRect(x: 0, y: 0, width: timetableViewController.view.frame.width, height: timetableViewController.view.frame.height / 2)
        self.presentSemiViewController(timetableViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

