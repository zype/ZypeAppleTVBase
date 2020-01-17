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
    
    func machineName() -> String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let deviceModel = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters)
        
        return deviceModel ?? ""
    }
    
    func sysUserAgent() ->  String? {
        let webViewClass: AnyObject.Type = NSClassFromString("UIWebView")!
        let webViewObject: NSObject.Type = webViewClass as! NSObject.Type
        let webView: AnyObject = webViewObject.init()
        let userAgent = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent")
        return userAgent
    }
    
    func userAgent() ->  String? {
        let machine = machineName();
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"]
        let sysAgent = sysUserAgent()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        var user_agent: String? = nil
        if sysAgent != nil {
            if var sysAgent = sysAgent, let range = sysAgent.range(of:"iPhone;"), let appName = appName, let version = version {
                sysAgent.replaceSubrange(range, with: "\(machine);")
                user_agent = "\(sysAgent) \(appName)/\(version)"
            }
            else if var sysAgent = sysAgent, let range = sysAgent.range(of:"Apple TV;"), let appName = appName, let version = version {
                sysAgent.replaceSubrange(range, with: "\(machine);")
                user_agent = "\(sysAgent) \(appName)/\(version)"
            }
            #if os(tvOS)
            if var user_agent_temp = user_agent, let range = user_agent_temp.range(of:"iPhone OS") {
                user_agent_temp.replaceSubrange(range, with: "\(UIDevice.current.systemName)")
                user_agent = user_agent_temp
            }
            #endif
        }
        return user_agent
    }
    
    // add check here to see if user is logged in and if he is change url with access token
    
    fileprivate var kPlayerGetVideo:String {
        let uuid = ZypeAppSettings.sharedInstance.deviceId()
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        let appBundle = "" //Bundle.main.bundleIdentifier
        let deviceType = 7
        let deviceMake = "Apple"
        let deviceModel = "AppleTV"
        let deviceIfa = ASIdentifierManager.shared().advertisingIdentifier
        let vpi = "mp4"
        let appId = ZypeAppSettings.sharedInstance.deviceId()
        
        var strUrl = "%@/embed/%@.json?app_key=%@&dvr=false&uuid=\(uuid)&app_name=\(appName)&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=\(deviceType)&device_make=\(deviceMake)&device_model=\(deviceModel)&device_ifa=[device_ifa]&vpi=\(vpi)&app_id=\(appId)&device_ua=[device_ua]"
        if ((ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn) == true){
            strUrl = "%@/embed/%@.json?access_token=%@&dvr=false&uuid=\(uuid)&app_name=\(appName)&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=\(deviceType)&device_make=\(deviceMake)&device_model=\(deviceModel)&device_ifa=[device_ifa]&vpi=\(vpi)&app_id=\(appId)&device_ua=[device_ua]"
        }
        strUrl = (strUrl as NSString).replacingOccurrences(of: "[app_bundle]", with: "\(appBundle)")
        strUrl = (strUrl as NSString).replacingOccurrences(of: "[app_domain]", with: "\(appBundle)")
        
        if let ifa = deviceIfa {
            strUrl = (strUrl as NSString).replacingOccurrences(of: "[device_ifa]", with: "\(ifa)")
        }
        if let ua = userAgent() {
            strUrl = (strUrl as NSString).replacingOccurrences(of: "[device_ua]", with: "\(ua)")
        }
        // finally replace spaces by hyphen
        strUrl = (strUrl as NSString).replacingOccurrences(of: " ", with: "-")
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
