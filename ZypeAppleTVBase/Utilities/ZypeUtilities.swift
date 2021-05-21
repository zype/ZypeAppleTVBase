//
//  ZypeUtilities.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 7/29/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

open class ZypeUtilities {
    
    //MARK: - Device Linking zObject.
    //Needs to be configured in admin panel for device linking to work
    
    public static func loadDeviceLinkingZObject() {
        let type = QueryZobjectsModel()
        type.zobjectType = "device_linking"
        ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: {(objects: Array<ZobjectModel>?, error: NSError?) in
            if let _ = objects, objects!.count > 0 {
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
    public static func presentFrameworkVC(_ caller: UIViewController) {
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        
        if let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "DeviceLinkingVC")
                caller.present(vc, animated: true, completion: nil)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
            
        }
    }
    
    public static func presentDeviceLinkingVC(_ caller: UIViewController, deviceLinkingUrl: String) {
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        
        if let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "DeviceLinkingVC") as! DeviceLinkingVC
                vc.deviceLinkingUrl = deviceLinkingUrl
                caller.present(vc, animated: true, completion: nil)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
            
        }
    }
    
    public static func isDeviceLinked() -> Bool {
        return UserDefaults.standard.bool(forKey: kDeviceLinkedStatus)
    }
    
    public static func checkDeviceLinkingWithServer() {
        let deviceString = ZypeAppSettings.sharedInstance.deviceId()
        ZypeAppleTVBase.sharedInstance.getLinkedStatus(deviceString, completion: {(status: Bool?, pin: String?, error: NSError?) in
            if status == true {
                UserDefaults.standard.set(true, forKey: kDeviceLinkedStatus)
                loginConsumerToGetToken(deviceString, pin: pin)
            } else {
                UserDefaults.standard.set(false, forKey: kDeviceLinkedStatus)
                ZypeAppleTVBase.sharedInstance.logOut()
            }
        })
    }
    
    //MARK: - Login with token
    public static func loginConsumerToGetToken(_ deviceId: String, pin: String?) {
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
    
    public static func imageFromResourceBundle(_ imageName: String) -> UIImage? {
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        if let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                let imagePath = bundle.path(forResource: imageName, ofType: "")
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
            if let _ = objects, objects!.count > 0 {
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
        ZypeAppSettings.sharedInstance.limitLivestream.starts = Date().timeIntervalSince1970
    }
    
    public static func livestreamStopped() {
        let playedForDuration = Int(Date().timeIntervalSince1970 - ZypeAppSettings.sharedInstance.limitLivestream.starts)
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
    
    // MARK: - Login
    public static func presentLoginVC(_ caller: UIViewController, _ subscribeDelegate: SubscriptionDelegate? = nil, isFavoriteFlow: Bool = false) {
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        
        if let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                vc.subscribeDelegate = subscribeDelegate
                vc.isFavoriteFlow = isFavoriteFlow
                caller.present(vc, animated: true, completion: nil)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
            
        }
    }
    
    public static func presentLoginVC(_ caller: UIViewController, _ dismissParent: Bool, _ subscribeDelegate: SubscriptionDelegate? = nil ) {
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        
        if let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                if dismissParent {
                    vc.dismissParentController = caller
                }
                vc.subscribeDelegate = subscribeDelegate
                caller.present(vc, animated: true, completion: nil)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
            
        }
    }
    
    public static func presentRegisterVC(_ caller: UIViewController, _ subscribeDelegate: SubscriptionDelegate? = nil) {
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        
        guard let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") else {
            assertionFailure("Could not create a path to the bundle")
            return
        }
        
        guard let bundle = Bundle(url: bundleURL) else {
            assertionFailure("Could not load the bundle")
            return
        }
        
        let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        vc.subscribeDelegate = subscribeDelegate
        caller.present(vc, animated: true, completion: nil)
    }
    
    public static func loginUser(_ completion: @escaping (_ result: String) -> Void) {
        let email =  UserDefaults.standard.object(forKey: kUserEmail) as! String?
        let password = UserDefaults.standard.object(forKey: kUserPassword) as! String?
        
        if email == nil || password == nil {
            completion("Not logged in")
            UserDefaults.standard.set(false, forKey: kDeviceLinkedStatus)
        }
        else {
            ZypeAppleTVBase.sharedInstance.login(email!, passwd: password!, completion:{ (loggedIn: Bool, error: NSError?) in
                if error != nil {
                    completion("error")
                    return
                }
                
                if loggedIn {
                    UserDefaults.standard.set(true, forKey: kDeviceLinkedStatus)
                    if (ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn) == true {
                        print("YaY")
                    }
                    else {
                        print("Nay :(")
                    }
                }
                else {
                    UserDefaults.standard.set(false, forKey: kDeviceLinkedStatus)
                }
                completion("Completed")
            })
        }
    }
    
    public static func getLogoutVC() -> LogoutVC? {
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        
        if let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                let storyboard = UIStoryboard(name: "DeviceLinking", bundle: bundle)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "LogoutVC") as! LogoutVC
                return vc
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
            
        }
        
        return nil
    }
}
