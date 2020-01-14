//
//  EyeInTheSky.swift
//  NASA-API-APP
//
//  Created by Cristian Sedano Arenas on 09/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import UIKit
import MapKit

class EyeInTheSkyViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var locationName: String?
    var locationLatitude: Double?
    var locationLongitude: Double?
    
    //Map properties
    let locationManager:CLLocationManager =  LocationManager.sharedLocationManager.locationManager
    let regionInMeters: Double = 2000
    var previousLocation: CLLocation?
    
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getImage(_ sender: Any) {
        getPhoto()
    }
    
    //MARK: - Methdods
    func createEarthImageURL(with coordinate: CLLocationCoordinate2D) -> URL? {
        let latLong: (lat: Double, long: Double) = (lat: coordinate.latitude, long: coordinate.longitude)
        
        let nasaAPIString = "\(Service.nasaURL)\(Types.eyeInTheSky.urlString)?&lon=\(latLong.long)&lat=\(latLong.lat)&cloud_score=True&api_key=\(Service.apiKey)"
        
        guard let url: URL = URL(string: nasaAPIString) else { return nil }
        
        return url
    }
    
    func getPhoto() {
        
        guard let coordinate2d = LocationManager.sharedLocationManager.currentLocation?.coordinate else { return }
        guard let url = createEarthImageURL(with: coordinate2d) else { return }
        
        JSONDownloader().downloadJSON(for: .eyeInTheSky, at: url, vc: self) { (locationData, error) in
            if let error = error {
                self.generalAlert(title: "Error", message: "There was an error downloading your data. Please check your connection and try again.\n\nError: \(error.localizedDescription)")
                return
            }
            
            guard let data = locationData as? EarthImage else {  return }
            
            if let urlString = URL(string: data.url) {
                ImageService.getImage(withURL: urlString) { image in
                    self.imageView.image = image
                }
            }
        }
    }
}

extension EyeInTheSkyViewController: MapToReminderProtocol {
    func sendDataToReminderVC(name: String, latitude: Double, longitude: Double) {
        locationName = name
        locationLatitude = latitude
        locationLongitude = longitude
    }
}
