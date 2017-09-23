//
//  detailsVC.swift
//  FoursquareCloneParse
//
//  Created by Samet ÇELİKBIÇAK on 23.09.2017.
//  Copyright © 2017 Samet ÇELİKBIÇAK. All rights reserved.
//

import UIKit
import Parse
import MapKit

class detailsVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var placeAtmosphereLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var selectedPlace = ""
    var nameArray = [String]()
    var typeArray = [String]()
    var atmosphereArray = [String]()
    var latitudeArray = [String]()
    var longitudeArray = [String]()
    var imageArray = [PFFile]()
    var chosenLatitude = ""
    var chosenLongitude = ""
    var manager = CLLocationManager()
    var requestCLLocation = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        findPlaceFromServer()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.chosenLongitude != "" && self.chosenLatitude != "" {
            let location = CLLocationCoordinate2D(latitude: Double(self.chosenLatitude)!, longitude: Double(self.chosenLongitude)!)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            self.mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = self.nameArray.last!
            annotation.subtitle = self.typeArray.last!
            self.mapView.addAnnotation(annotation)
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if self.chosenLongitude != "" && self.chosenLatitude != "" {
            self.requestCLLocation = CLLocation(latitude:Double(self.chosenLatitude)!, longitude: Double(self.chosenLongitude)!)
            CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let mkPlaceMark = MKPlacemark(placemark: placemark[0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.nameArray.last!
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                }
            })
        }
    }
    
    func findPlaceFromServer() {
        let query = PFQuery(className: "Places")
        query.whereKey("name", equalTo: self.selectedPlace)
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.nameArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.atmosphereArray.removeAll(keepingCapacity: false)
                self.imageArray.removeAll(keepingCapacity: false)
                self.latitudeArray.removeAll(keepingCapacity: false)
                self.longitudeArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.nameArray.append(object.object(forKey: "name") as! String)
                    self.typeArray.append(object.object(forKey: "type") as! String)
                    self.atmosphereArray.append(object.object(forKey: "atmosphere") as! String)
                    self.imageArray.append(object.object(forKey: "image") as! PFFile)
                    self.latitudeArray.append(object.object(forKey: "latitude") as! String)
                    self.longitudeArray.append(object.object(forKey: "longitude") as! String)
                    
                    self.placeNameLabel.text = "Name: \(self.nameArray.last!)"
                    self.placeTypeLabel.text = "Type: \(self.typeArray.last!)"
                    self.placeAtmosphereLabel.text = "Atmosphere: \(self.atmosphereArray.last!)"
                    self.chosenLatitude = self.latitudeArray.last!
                    self.chosenLongitude = self.longitudeArray.last!
                    self.manager.startUpdatingLocation()
                    self.imageArray.last?.getDataInBackground(block: { (data, error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.placeImage.image = UIImage(data: data!)
                        }
                    })
                }
            }
            
        }
    }
    
}
