//
//  AppSettings.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 5/11/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

public struct LimitLivestream {
    public var limit: Int = 0
    public var played: Int = 0
    public var message: String = ""
    public var refreshRate: Int = 0
    public var starts: NSTimeInterval = 0
    public var isSet = false
}

public struct DeviceLinking {
    public var isEnabled = false
    public var played: Int = 0
    public var message: String = ""
    public var refreshRate: Int = 0
    public var starts: NSTimeInterval = 0
    public var isSet = false
}

private let sharedInstance = ZypeAppSettings()

public class ZypeAppSettings {
    
    public static let sharedInstance = ZypeAppSettings()
    
    public var appVersion = "1.0.0"
    
    public var limitLivestream = LimitLivestream()
    
    public var deviceLinking = DeviceLinking()
    
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