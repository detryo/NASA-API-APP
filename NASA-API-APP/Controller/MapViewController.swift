//
//  MapViewController.swift
//  NASA-API-APP
//
//  Created by Cristian Sedano Arenas on 09/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import UIKit
import MapKit
import Intents
import Contacts
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

protocol MapToReminderProtocol {
    func sendDataToReminderVC(name: String, latitude: Double, longitude: Double)
}

class MapViewController: UIViewController {
    
    var resultSearchController = UISearchController()
    var selectedPin: MKPlacemark? = nil
    
    var mapToReminder: MapToReminderProtocol?
    
    var startingLocation: String = ""
    var locationLatitude: Double?
    var locationLongitude: Double?
    var locationName: String?
    var circle: MKCircle?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if let lat = locationLatitude, let lon = locationLongitude, let name = locationName {
            
            let location = CLLocation(latitude: lat, longitude: lon)
            let locationPlacemark = CLPlacemark(location: location, name: name, postalAddress: nil)
            let pin = MKPlacemark(placemark: locationPlacemark)
            dropPinZoomIn(placemark: pin)
        } else {
            loadInitialMapViewBasedOnLocation(LocationManager.sharedLocationManager.locationManager, location: LocationManager.sharedLocationManager.lastLocation)
        }
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Enter location"
        navigationItem.titleView = resultSearchController.searchBar
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor(red: 0.0196, green: 0.498, blue: 1.0, alpha: 1.0)
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self as HandleMapSearch
    }
    
    func loadInitialMapViewBasedOnLocation(_ manager: CLLocationManager, location: CLLocation) {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality, let state = placemark.administrativeArea, let name = placemark.name {
            
            annotation.subtitle = "\(city) \(state)"
            startingLocation = "\(name)"
        }
        
        LocationManager.sharedLocationManager.currentLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        mapToReminder?.sendDataToReminderVC(name: startingLocation, latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        mapView.addAnnotation(annotation)
        
        
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        if let lat = locationLatitude, let lon = locationLongitude {
            
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            circle = MKCircle(center: center, radius: LocationManager.sharedLocationManager.geoFenceRadius)
            if let myCircle = circle {
                mapView.addOverlay(myCircle as MKOverlay)
            }
        }
        
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        if annotation is MKUserLocation { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.red
        pinView?.canShowCallout = true
        pinView?.isSelected = true
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
}
