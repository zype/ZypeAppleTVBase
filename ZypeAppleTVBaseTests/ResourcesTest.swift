//
//  ResourcesTest.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 7/28/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import XCTest
import ZypeAppleTVBase


class ResourcesTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResourceBundle() {
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        if let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                XCTAssertNotNil(bundle)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
        }
    }


    func testGetStoryboard() {
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        if let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "DeviceLinkingVC")
                XCTAssertNotNil(vc)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
