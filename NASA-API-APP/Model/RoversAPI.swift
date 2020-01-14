//
//  RoversAPI.swift
//  NASA-API-APP
//
//  Created by Cristian Sedano Arenas on 09/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import UIKit

enum RoversError: Error {
    case invalidJSONData
}

enum Method: String {
    case curiosity = "curiosity"
    case opportunity = "opportunity"
    case spirit = "spirit"
}

struct RoversAPI {
    
    typealias JSON = [String: String]
    
    private static let baseURLString = "https://api.nasa.gov/mars-photos/api/v1/rovers"
    private static let apiKey = "RzsvdoF19aRRiE9gwNblmOfKIrO2QWbf1Bl46qXW"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    
    
    private static func roversURL(method: Method, parameters: [String:String]?) -> URL {
        
        let urlStr = "\(baseURLString)/\(method.rawValue)/photos"
        var components = URLComponents(string: urlStr)
        var queryItems = [URLQueryItem]()
        let baseParams = [ "sol": "1000", "api_key": apiKey ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components?.queryItems = queryItems
        return (components?.url!)!
    }
    
    static var curiosityPhotosURL: URL {
        return roversURL(method: .curiosity, parameters: ["extras": "url_h,date_taken"])
    }
    
    static var opportunityPhotosURL: URL {
        return roversURL(method: .opportunity, parameters: ["extras": "url_h,date_taken"])
    }
    
    static var spiritPhotosURL: URL {
        return roversURL(method: .spirit, parameters: ["extras": "url_h,date_taken"])
    }
    
    static func photos(fromJSON data: Data) -> PhotosResult {
        do {
            var objectData: ObjectModel?
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let objects = try decoder.decode(RoverData.self, from: data)
            objectData = objects
            
            let roverData = objectData as? RoverData
            
            guard let roverImages = roverData?.photos else { return .failure(RoversError.invalidJSONData) }
            
            return .success(roverImages)
        } catch let error {
            return .failure(error)
        }
    }
}
