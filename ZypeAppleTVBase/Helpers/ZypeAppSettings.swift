//
//  AppSettings.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 5/11/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

private let sharedInstance = ZypeAppSettings()

public class ZypeAppSettings {
    
    public static let sharedInstance = ZypeAppSettings()
    
    public var appVersion = "1.0.0"
    
    private init() {
        
    }
    
    
    public func deviceId() -> String {
        var deviceID = NSUserDefaults().valueForKey("device")
        
        if(deviceID == nil) {
            deviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
            print(deviceID)
            NSUserDefaults().setValue(deviceID, forKey: "device")
        }
        
        return deviceID as! String
    }
    
}