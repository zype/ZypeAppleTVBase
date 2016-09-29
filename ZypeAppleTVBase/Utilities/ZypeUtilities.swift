//
//  ZypeUtilities.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 7/29/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

public class ZypeUtilities {
    
    //MARK: - Device Linking zObject. 
    //Needs to be configured in admin panel for device linking to work

    public static func loadDeviceLinkingZObject() {
        let type = QueryZobjectsModel()
        type.zobjectType = "device_linking"
        ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: {(objects: Array<ZobjectModel>?, error: NSError?) in
            if let _ = objects where objects!.count > 0 {
               //enable device linking in the app
                 ZypeAppSettings.sharedInstance.deviceLinking.isEnabled = true
                
                //load url for the client
                 let dLinking = objects?.first
                ZypeAppSettings.sharedInstance.deviceLinking.linkUrl =  (dLinking?.getStringValue("link_url"))!
                
                //check if device is linked
                 ZypeUtilities.checkDeviceLinkingWithServer()
                
            } else {
                print("no zObject Device Linking")
                ZypeAppSettings.sharedInstance.deviceLinking.isEnabled = false
            }
        })
    }
    
    //MARK: - Device Linking
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
    
    public static func checkDeviceLinkingWithServer() {
        let deviceString = ZypeAppSettings.sharedInstance.deviceId()
        ZypeAppleTVBase.sharedInstance.getLinkedStatus(deviceString, completion: {(status: Bool?, pin: String?, error: NSError?) in
            if status == true {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDeviceLinkedStatus)
                loginConsumerToGetToken(deviceString, pin: pin)
            } else {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDeviceLinkedStatus)
                ZypeAppleTVBase.sharedInstance.logOut()
            }
        })
    }
    
    //MARK: - Login with token
    public static func loginConsumerToGetToken(deviceId: String, pin: String?) {
        if (pin != nil) {
            ZypeAppleTVBase.sharedInstance.login(deviceId, pin: pin!, completion: {(loggedIn: Bool?, error: NSError?) in
                if loggedIn == true {
                    print("logged in")
                } else {
                    print("not logged in")
                }
            })
        }
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
    
    //MARK: - Limit Livestream
    public static func loadLimitLivestreamZObject() {
        let type = QueryZobjectsModel()
        type.zobjectType = "limit_livestream"
        ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: {(objects: Array<ZobjectModel>?, error: NSError?) in
            if let _ = objects where objects!.count > 0 {
                let limitLivestream = objects?.first
                do {
                    ZypeAppSettings.sharedInstance.limitLivestream.limit = try SSUtils.intagerFromDictionary(limitLivestream?.json, key: "limit")
                    ZypeAppSettings.sharedInstance.limitLivestream.isSet = true
                }
                catch _ {
                     ZypeLog.error("Exception: ZobjectModel - Limit")
                }
                 ZypeAppSettings.sharedInstance.limitLivestream.refreshRate = Int((limitLivestream?.getStringValue("refresh_rate"))!)!
                
                ZypeAppSettings.sharedInstance.limitLivestream.message =  (limitLivestream?.getStringValue("message"))!
            }
        })
    }
    
    public static func livestreamStarts() {
        ZypeAppSettings.sharedInstance.limitLivestream.starts = NSDate().timeIntervalSince1970
    }
    
    public static func livestreamStopped() {
        let playedForDuration = Int(NSDate().timeIntervalSince1970 - ZypeAppSettings.sharedInstance.limitLivestream.starts)
         ZypeAppSettings.sharedInstance.limitLivestream.played = ZypeAppSettings.sharedInstance.limitLivestream.played + playedForDuration
        print("stopped playing: \(ZypeAppSettings.sharedInstance.limitLivestream.played)")
    }
    
    public static func livestreamLimitReached() -> Bool {
       //if limit livestream not set return false
        if (!ZypeAppSettings.sharedInstance.limitLivestream.isSet){
            return false
        }
        
        if (ZypeAppSettings.sharedInstance.limitLivestream.limit < ZypeAppSettings.sharedInstance.limitLivestream.played){
            return true
        } else {
            return false
        }
    }
    
    //MARK: - Login
    public static func presentLoginVC(caller: UIViewController) {
        let podBundle = NSBundle(forClass: ZypeAppleTVBase.self)
        
        if let bundleURL = podBundle.URLForResource("ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = NSBundle(URL: bundleURL) {
                let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
                
                let vc = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
                caller.presentViewController(vc, animated: true, completion: nil)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
            
        }
    }
    
    public static func loginUser() {
        let email =  NSUserDefaults.standardUserDefaults().objectForKey(kUserEmail) as! String?
        let password = NSUserDefaults.standardUserDefaults().objectForKey(kUserPassword) as! String?

        if ((email == nil) || (password == nil)){
              NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDeviceLinkedStatus)
        } else {
            ZypeAppleTVBase.sharedInstance.login(email!, passwd: password!, completion:{ (logedIn: Bool, error: NSError?) in
                print(logedIn)
                if (error != nil) {
                    
                    return
                }
                
                if (logedIn){
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDeviceLinkedStatus)
                    
                } else {
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDeviceLinkedStatus)
                }
                
            })
        }
       
    }
}
