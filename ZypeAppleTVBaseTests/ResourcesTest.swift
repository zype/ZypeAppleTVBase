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
       
        
        let resourcesBundlePath = (NSBundle.mainBundle().resourcePath! as NSString).stringByAppendingPathComponent("ZypeAppleTVBaseResources.bundle")
        
        let podBundle = NSBundle(path: resourcesBundlePath)
        
        XCTAssertNotNil(podBundle)
    }
    
    func testGetStoryboard() {
        let resourcesBundlePath = (NSBundle.mainBundle().resourcePath! as NSString).stringByAppendingPathComponent("ZypeAppleTVBaseResources.bundle")
        
        let podBundle = NSBundle(path: resourcesBundlePath)
        let storyboard = UIStoryboard(name: "DeviceLinking", bundle: podBundle)
        XCTAssertNotNil(storyboard)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
