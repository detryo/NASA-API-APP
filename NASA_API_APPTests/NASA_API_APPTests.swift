//
//  NASA_API_APPTests.swift
//  NASA_API_APPTests
//
//  Created by Cristian Sedano Arenas on 15/01/2020.
//  Copyright © 2020 Cristian Sedano Arenas. All rights reserved.
//

import XCTest
@testable import NASA_API_APP

class NASA_API_APPTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPhotoStore() {
        
        let store = PhotoStore()
        
        store.fetchInterestingPhotos(rover: 0) {
        (photosResult) -> Void in
           XCTAssertNotNil(photosResult, "Failed to load photos")
        }
    }
    
    func testLoadSingeImage() {
        let store = PhotoStore()
        
        let roverImage = RoverImage(imgSrc: "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/01000/opgs/edr/fcam/FLB_486265257EDR_F0481570FHAZ00323M_.JPG", sol: 1, id: 102693)
        
        store.fetchImage(for: roverImage) { (imageResult) in
            XCTAssertNotNil(imageResult, "Failed to load rover photo")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
