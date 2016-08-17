//
//  VimeoUrl.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/30/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

class VimeoUrl: BaseUrl, VideoUrl {

    // add check here to see if user is logged in and if he is change url with access token
    
    private var kPlayerGetVideo:String {
        if ((ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn) == true){
            return "%@/embed/%@.json?access_token=%@&dvr=false"
        } else {
            return "%@/embed/%@.json?app_key=%@&dvr=false"
        }
    }
    

     func getVideoObject(video: VideoModel, completion:(playerObject: VideoObjectModel, error: NSError?) -> Void)
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
    
    func callVideoObject(url: String, completion:(playerObject: VideoObjectModel, error: NSError?) -> Void)
    {
        self.controller!.getQuery(url, withCompletion: { (jsonDic, error) -> Void in
            let player = VideoObjectModel()
            player.json = jsonDic
            let response = jsonDic?[kJSONResponse]
            if response != nil
            {
                let outputs = response?[kJSONBody]?![kJSONOutputs] as? Array <Dictionary<String, String> >
                if outputs?.first != nil
                {
                    player.videoURL = outputs!.first![kJSONUrl]!
                }
            }
            completion(playerObject: player, error: error)
        })
    }
    
}
