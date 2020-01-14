//
//  EyeInTheSkyAPI.swift
//  NASA-API-APP
//
//  Created by Cristian Sedano Arenas on 09/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import UIKit

class JSONDownloader {
    
    typealias ObjectCompletionHandler = (ObjectModel?, Error?) -> Void
    
    func downloadJSON(for object: Types, at url: URL, vc: UIViewController, completion:@escaping ObjectCompletionHandler) {
        
        var objectData: ObjectModel?
        let session: URLSession = URLSession.shared
        var jsonError: Error?
        
        // Get data Eye In The Sky Data
        let task: URLSessionDownloadTask = session.downloadTask(with: url) { urlLocation, urlResponse, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    vc.generalAlert(title: "Error", message: "There was an error getting the Eye In The Sky data: \(error.localizedDescription)")
                }
                return
            }
            
            if let urlLocation = urlLocation {
                if let data = try? Data(contentsOf: urlLocation) {
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    switch object {
                    case .marsRover:
                        do {
                            let objects = try decoder.decode(RoverData.self, from: data)
                            objectData = objects
                        } catch {
                            jsonError = error
                        }
                    case .eyeInTheSky:
                        do {
                            let object = try decoder.decode(EarthImage.self, from: data)
                            objectData = object
                        } catch {
                            jsonError = error
                        }
                        
                    }
                }
                completion(objectData, jsonError)
            }
            
        }
        task.resume()
    }
}
