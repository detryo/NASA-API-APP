//
//  Data.swift
//  NASA-API-APP
//
//  Created by Cristian Sedano Arenas on 09/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import Foundation

enum Types {
    case marsRover
    case eyeInTheSky
    
    
    var urlString: String {
        switch self {
        case .marsRover: return "mars-photos/api/v1/rovers/"
        case .eyeInTheSky: return "planetary/earth/imagery/"
        }
    }
}

struct Service {
    static let apiKey = "RzsvdoF19aRRiE9gwNblmOfKIrO2QWbf1Bl46qXW"
    static let nasaURL: String = "https://api.nasa.gov/"
}



