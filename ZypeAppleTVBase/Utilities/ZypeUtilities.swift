//
//  ZypeUtilities.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 7/29/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

public class ZypeUtilities {
    
    public static func presentFrameworkVC(caller: UIViewController) {
        let podBundle = NSBundle(forClass: ZypeAppleTVBase.self)
        
        if let bundleURL = podBundle.URLForResource("ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = NSBundle(URL: bundleURL) {
                let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
                
                let vc = storyboard.instantiateViewControllerWithIdentifier("DeviceLinkingVC")
                caller.presentViewController(vc, animated: true, completion: nil)
            }else {
                assertionFailure("Could not load the bundle")
                }
        }else {
            assertionFailure("Could not create a path to the bundle")
            
        }
    }
    
    public static func presentDeviceLinkingVC(caller: UIViewController, deviceLinkingUrl: String) {
        let podBundle = NSBundle(forClass: ZypeAppleTVBase.self)
        
        if let bundleURL = podBundle.URLForResource("ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = NSBundle(URL: bundleURL) {
                let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
                
                let vc = storyboard.instantiateViewControllerWithIdentifier("DeviceLinkingVC") as! DeviceLinkingVC
                vc.deviceLinkingUrl = deviceLinkingUrl
                caller.presentViewController(vc, animated: true, completion: nil)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
            
        }
    }
    
    public static func isDeviceLinked() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(kDeviceLinkedStatus)
    }
    
    public static func imageFromResourceBundle(imageName: String) -> UIImage? {
        let podBundle = NSBundle(forClass: ZypeAppleTVBase.self)
        if let bundleURL = podBundle.URLForResource("ZypeAppleTVBaseResources", withExtension: "bundle") {
            if let bundle = NSBundle(URL: bundleURL) {
                let imagePath = bundle.pathForResource(imageName, ofType: "")
                if imagePath != nil {
                    return UIImage(contentsOfFile: imagePath!)!
                }
            }
        }
        return nil
    }
    
}