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
    @IBOutlet var centerImageView: UIImageView!
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
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location : CLLocation = locations[0] as! CLLocation
        currentLocation = location.coordinate
        
        if initLocation == false {
            doInitLocation()
        }
    }
    
    private func doInitLocation() {
        initLocation = true
        MapView.showsUserLocation = false
        centerMap(location: currentLocation)
    }
    
    @IBAction func onButtonPress(sender: AnyObject) {
        centerMap(location: currentLocation)
    }
    
    func centerMap(location loc : CLLocationCoordinate2D?) {
        if loc == nil {
            return;
        }
        
        var mapRegion : MKCoordinateRegion!
        mapRegion = MKCoordinateRegion()
        mapRegion.center = loc!
        mapRegion.span.latitudeDelta = 0.01
        mapRegion.span.longitudeDelta = 0.01
        
        MapView.delegate = self
        MapView.setRegion(mapRegion, animated: true)
        getStops(location: loc!)
    }
    
    func getStops(location loc : CLLocationCoordinate2D) {
        var url = "http://transportapi.com/v3/uk/bus/stops/near.json?lat=\(loc.latitude)&lon=\(loc.longitude)&api_key=e2c96777c715a5d317c9d2016fdf5284&app_id=b4d09e5d"
        
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
    
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        if currentLocation == nil {
            return;
        }
        
        if (MapView.region.span.latitudeDelta > 0.02) || (MapView.region.span.longitudeDelta > 0.02) {
            MapView.removeAnnotations(annotations)
            return;
        }
        
        let hasChanged = (MapView.centerCoordinate.latitude != currentLocation.latitude)
            || (MapView.centerCoordinate.longitude != currentLocation.longitude);
        
        if hasChanged {
            getStops(location: MapView.centerCoordinate)
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        centerImageView.hidden = true
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        centerImageView.hidden = false
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

