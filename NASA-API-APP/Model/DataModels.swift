//
//  DataModels.swift
//  NASA-API-APP
//
//  Created by Cristian Sedano Arenas on 09/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import UIKit

//Protocol used so that JSONDownloader can utilize either RoverData or EarthImage
protocol ObjectModel {}

//Mars Rover
struct RoverData: Codable, ObjectModel {
    var photos: [RoverImage]
}

struct RoverImage: Codable {
    var imgSrc: String
    var sol: Int
    var id: Int
}

struct Camera: Codable {
    var id: String
    var name: String
    var fullName: String
}

struct EarthData: Codable, ObjectModel {
    var photo: EarthImage
}

//Eye in the Sky
struct EarthImage: Codable, ObjectModel {
    var cloudScore: Double
    var date: String
    var url: String
}

extension RoverImage: Equatable {
   static func == (lhs: RoverImage, rhs: RoverImage) -> Bool {
        return lhs.id == rhs.id
    }
}
