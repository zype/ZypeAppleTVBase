//
//  GuideProgramModel.swift
//  ZypeAppleTVBase
//
//  Created by Top developer on 4/19/19.
//

import UIKit

open class GuideProgramModel: NSObject {
    
    fileprivate (set) open var ID = ""
    fileprivate (set) open var title = ""
    fileprivate (set) open var programDescription = ""
    fileprivate (set) open var start_time: Date?
    fileprivate (set) open var end_time: Date?
    fileprivate (set) open var localStartTime: Date?
    fileprivate (set) open var localEndTime: Date?
    fileprivate (set) open var duration = 0
    
    init(json: Dictionary<String, AnyObject>)
    {
        super.init()
        do
        {
            self.ID = try SSUtils.stringFromDictionary(json, key: kJSON_Id)
        }
        catch
        {
            ZypeLog.error("Exception: GuideProgramModel")
        }
        do
        {
            self.title = try SSUtils.stringFromDictionary(json, key: kJSONTitle)
        }
        catch
        {
            ZypeLog.error("Exception: GuideProgramModel title")
        }
        do
        {
            self.programDescription = try SSUtils.stringFromDictionary(json, key: kJSONDescription)
        }
        catch
        {
            ZypeLog.error("Exception: GuideProgramModel description")
        }
        do
        {
            self.start_time = SSUtils.stringToDate(try SSUtils.stringFromDictionary(json, key: kJSONStartTime))
            self.localStartTime = Calendar.current.date(byAdding: .second, value: -TimeZone.current.secondsFromGMT(), to: self.start_time!)
        }
        catch
        {
            ZypeLog.error("Exception: GuideProgramModel start time")
        }
        do
        {
            self.end_time = SSUtils.stringToDate(try SSUtils.stringFromDictionary(json, key: kJSONEndTime))
            self.localEndTime = Calendar.current.date(byAdding: .second, value: -TimeZone.current.secondsFromGMT(), to: self.end_time!)
        }
        catch
        {
            ZypeLog.error("Exception: GuideProgramModel end time")
        }
        do
        {
            self.duration = try SSUtils.intagerFromDictionary(json, key: kJSONDuration)
        }
        catch
        {
            ZypeLog.error("Exception: GuideProgramModel duration")
        }
    }
    
    open var isAiring : Bool {
        return self.containsDate(Date())
    }
    
    open func containsDate(_ date: Date) -> Bool {
        if self.localStartTime == nil || self.localEndTime == nil {
            return false
        }
        return (self.localStartTime == date) || ((self.localStartTime! as NSDate).earlierDate(date) == self.localStartTime && (self.localEndTime! as NSDate).laterDate(date) == self.localEndTime && self.localEndTime != date)
    }
}
