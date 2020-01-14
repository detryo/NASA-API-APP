//
//  PhotoStore.swift
//  NASA-API-APP
//
//  Created by Cristian Sedano Arenas on 09/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import UIKit

enum PhotosResult {
    case success([RoverImage])
    case failure(Error)
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

class PhotoStore {
    
    let imageStore = EarthImageStore()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        
        guard let jsonData = data else { return .failure(error!) }
        
        return RoversAPI.photos(fromJSON: jsonData)
    }
    
    func fetchInterestingPhotos(rover: Int, completion: @escaping (PhotosResult) -> Void) {
        
        var  url = RoversAPI.curiosityPhotosURL
        
        if rover == 0 {
            url = RoversAPI.curiosityPhotosURL
        } else if rover == 1 {
                url = RoversAPI.opportunityPhotosURL
            } else {
                url = RoversAPI.spiritPhotosURL
        }
        
        print(url)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            
            let result = self.processPhotosRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func fetchImage(for photo: RoverImage, completion: @escaping (ImageResult) -> Void) {
        
        let photoKey = "\(photo.id)"
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        guard let photoURL = URL(string: photo.imgSrc) else { return }
        
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard let imageData = data, let image = UIImage(data: imageData) else {
            
            // Couldn't create an image
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(PhotoError.imageCreationError)
            }
        }
        return .success(image)
    }
}
