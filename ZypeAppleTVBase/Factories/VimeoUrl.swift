//
//  VimeoUrl.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/30/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit
import AdSupport

class VimeoUrl: BaseUrl, VideoUrl {
    
    // add check here to see if user is logged in and if he is change url with access token
    
    fileprivate var kPlayerGetVideo:String {
        let uuid = ZypeAppSettings.sharedInstance.deviceId()
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        let appBundle = Bundle.main.bundleIdentifier
        let deviceType = 7
        let deviceMake = "Apple"
        let deviceModel = "AppleTV"
        let deviceIfa = ASIdentifierManager.shared().advertisingIdentifier
        let vpi = "mp4"
        let appId = ZypeAppSettings.sharedInstance.deviceId()
        
        var strUrl = "%@/embed/%@.json?app_key=%@&dvr=false&uuid=\(uuid)&app_name=\(appName)&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=\(deviceType)&device_make=\(deviceMake)&device_model=\(deviceModel)&device_ifa=[device_ifa]&vpi=\(vpi)&app_id=\(appId)"
        if ((ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn) == true){
            strUrl = "%@/embed/%@.json?access_token=%@&dvr=false&uuid=\(uuid)&app_name=\(appName)&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=\(deviceType)&device_make=\(deviceMake)&device_model=\(deviceModel)&device_ifa=[device_ifa]&vpi=\(vpi)&app_id=\(appId)"
        }
        if let bundle = appBundle {
            strUrl = (strUrl as NSString).replacingOccurrences(of: "[app_bundle]", with: "\(bundle)")
            strUrl = (strUrl as NSString).replacingOccurrences(of: "[app_domain]", with: "\(bundle)")
        }
        if let ifa = deviceIfa {
            strUrl = (strUrl as NSString).replacingOccurrences(of: "[device_ifa]", with: "\(ifa)")
        }
        return strUrl
    }
    
    
    func getVideoObject(_ video: VideoModel, completion:@escaping (_ playerObject: VideoObjectModel, _ error: NSError?) -> Void)
    {
        if ((ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn) == true){
            //call with access token
            ZypeAppleTVBase.sharedInstance.getToken({
                (token: String?, error: NSError?) in
                let urlAsString = String(format: self.kPlayerGetVideo, self.controller!.keys.playerDomain, video.ID, token!)
                self.callVideoObject(urlAsString, completion: completion)
            })
        } else {
            //call with api key
            let urlAsString = String(format: kPlayerGetVideo, self.controller!.keys.playerDomain, video.ID, self.controller!.keys.appKey)
            callVideoObject(urlAsString, completion: completion)
        }
    }
    
    func callVideoObject(_ url: String, completion:@escaping (_ playerObject: VideoObjectModel, _ error: NSError?) -> Void)
    {
        _ = self.controller!.getQuery(url, withCompletion:{ (jsonDic, error) -> Void in
            let player = VideoObjectModel()
            player.json = jsonDic
            if let response = jsonDic?[kJSONResponse] as? NSDictionary
                
            {
                if let jsonBody = response[kJSONBody] as? NSDictionary {
                    let outputs = jsonBody[kJSONOutputs] as? Array <Dictionary<String, String> >
                    if outputs?.first != nil
                    {
                        player.videoURL = outputs!.first![kJSONUrl]!
                    }
                }
                
            }
            completion(player, error)
        })
    }
    
}
