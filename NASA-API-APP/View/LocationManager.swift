//
//  LocationManager.swift
//  NASA-API-APP
//
//  Created by Cristian Sedano Arenas on 09/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

// LocationManager used to registers locations

class LocationManager: NSObject {
    
    let geoFenceRadius = 50.0  // in meters
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    var lastLocation = CLLocation()
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    static let sharedLocationManager = LocationManager()
    
    @objc dynamic var currentLocation: CLLocation?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
    }
    
    func requestLocation() {
        
        guard CLLocationManager.locationServicesEnabled() else {
            displayLocationServicesDisabledAlert()
            return
        }
        
        let status = CLLocationManager.authorizationStatus()
        guard status != .denied else {
            displayLocationServicesDeniedAlert()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func displayLocationServicesDisabledAlert() {
        
        let message = NSLocalizedString("LOCATION_SERVICES_DISABLED", comment: "Location services are disabled")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: "OK alert button"), style: .default, handler: nil))
        displayAlert(alertController)
    }
    
    private func displayLocationServicesDeniedAlert() {
        
        let message = NSLocalizedString("LOCATION_SERVICES_DENIED", comment: "Location services are denied")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        let settingsButtonTitle = NSLocalizedString("BUTTON_SETTINGS", comment: "Settings alert button")
        let openSettingsAction = UIAlertAction(title: settingsButtonTitle, style: .default) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                // Take the user to the Settings app to change permissions.
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelButtonTitle = NSLocalizedString("BUTTON_CANCEL", comment: "Location denied cancel button")
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(openSettingsAction)
        displayAlert(alertController)
    }
    
    private func displayAlert(_ controller: UIAlertController) {
        
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("The key window did not have a root view controller")
        }
        viewController.present(controller, animated: true, completion: nil)
    }
    
    func registerGeoFence(lat: Double, lon: Double, identifier: String, onEntering: Bool) {
        
        if locationManager.monitoredRegions.count < 20 {
            let geoFenceRegionCenter = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let geoFenceRegion = CLCircularRegion(center: geoFenceRegionCenter, radius: geoFenceRadius, identifier: identifier)
            
            if onEntering {
                geoFenceRegion.notifyOnEntry = true
                geoFenceRegion.notifyOnExit = false
            } else {
                geoFenceRegion.notifyOnEntry = false
                geoFenceRegion.notifyOnExit = true
            }
            
            locationManager.startMonitoring(for: geoFenceRegion)
            addTrigger(for: geoFenceRegion)
        }
    }
    
    func removeGeoFence(for region: CLRegion) {
        
        for region in locationManager.monitoredRegions {
            
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == region.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    func addTrigger(for region: CLRegion) {
        
        let content = UNMutableNotificationContent()
        content.title = "Location:"
        content.body = region.identifier
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        addRequestToNotificationCenter(for: trigger, with: content)
    }
    
    func addRequestToNotificationCenter(for trigger: UNLocationNotificationTrigger, with content: UNMutableNotificationContent) {
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle any errors returns from Location Services.
    }
}
