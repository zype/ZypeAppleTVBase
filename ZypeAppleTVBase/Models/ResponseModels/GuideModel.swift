//
//  GuideModel.swift
//  ZypeAppleTVBase
//
//  Created by Top developer on 4/19/19.
//

import UIKit

open class GuideModel: NSObject {
    
    fileprivate (set) open var ID = ""
    fileprivate (set) open var name = ""
    fileprivate (set) open var video_id = ""
    
    open var programs = [GuideProgramModel]()
    
    init(json: Dictionary<String, AnyObject>)
    {
        super.init()
        do
        {
            self.ID = try SSUtils.stringFromDictionary(json, key: kJSON_Id)
            self.name = try SSUtils.stringFromDictionary(json, key: kJSONName)
            if let videoIds = json[kJSONVideoIds] as? [String], videoIds.count > 0 {
                self.video_id = videoIds[0]
            }
        }
        catch
        {
            ZypeLog.error("Exception: GuideModel")
        }
    }
}
