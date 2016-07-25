//
//  PlaylistModel.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/28/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

public class PlaylistModel: BaseModel {
 
    private(set) public var pId = ""
    private(set) public var descriptionString = ""
    private(set) public var keywords = Array<String>()
    private(set) public var active = false
    private(set) public var priority = 0
    private(set) public var createdAt: NSDate?
    private(set) public var updatedAt: NSDate?
    private(set) public var playlistItemCount = 0
    private(set) public var siteID = ""
    private(set) public var relatedVideoIDs = Array<String>()
    private(set) public var parentId = ""
    
    private(set) public var thumbnails = Array<ThumbnailModel>()
    private(set) public var images = Array<ThumbnailModel>()
    
    public init(fromJson: Dictionary<String, AnyObject>)
    {
        super.init(json: fromJson)
        do
        {
            self.pId = try SSUtils.stringFromDictionary(fromJson, key: kJSON_Id)
            self.descriptionString = try SSUtils.stringFromDictionary(fromJson, key: kJSONDescription)
            self.keywords = fromJson[kJSON_Keywords] as! Array<String>
            self.active = try SSUtils.boolFromDictionary(fromJson, key: kJSONActive)
            self.priority = try SSUtils.intagerFromDictionary(fromJson, key: kJSONPriority)
            self.createdAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONCreatedAt))
            self.updatedAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONUpdatedAt))
            self.playlistItemCount = try SSUtils.intagerFromDictionary(fromJson, key: kJSONPlaylistItemCount)
            self.siteID = try SSUtils.stringFromDictionary(fromJson, key: kJSONSiteId)
            self.relatedVideoIDs = fromJson[kJSONRelatedVideoIds] as! Array <String>
            self.parentId = try SSUtils.stringFromDictionary(fromJson, key: kJSONParentId)
        }
        catch _
        {
            ZypeLog.error("Exception: PlaylistModel")
        }
        self.loadThumbnails(fromJson[kJSONThumbnails] as? Array<AnyObject>)
        self.loadImages(fromJson[kJSONImages] as? Array<AnyObject>)
    }
    
    public func getVideos(loadedSince: NSDate = NSDate(), completion:(videos: Array<VideoModel>?, error: NSError?) -> Void)
    {
        let videos = self.userData["videos"]
        if (videos != nil)
        {
            if(loadedSince.compare(self.userData["date"] as! NSDate) == NSComparisonResult.OrderedAscending)
            {
                completion(videos: videos as? Array<VideoModel>, error: nil)
                return
            }
        }
        ZypeAppleTVBase.sharedInstance.retrieveVideosInPlaylist(QueryRetrieveVideosInPlaylistModel(playlist: self), completion:{(videos, error) -> Void in
            self.userData["videos"] = videos
            self.userData["date"] = NSDate()
            completion(videos: videos, error: error)
        })
    }

    private func loadThumbnails(thumbnails: Array<AnyObject>?)
    {
        do
        {
            if (thumbnails != nil)
            {
                for value in thumbnails!
                {
                    let height = try SSUtils.intagerFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONHeight)
                    let width = try SSUtils.intagerFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONWidth)
                    let url = try SSUtils.stringFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONUrl)
                    let nameValue = value[kJSONName]
                    let name = ((nameValue as? String) != nil) ? (nameValue as! String) : ""
                    self.thumbnails.append(ThumbnailModel(height: height, width: width, url: url, name: name))
                }
            }
        }
        catch _
        {
            ZypeLog.error("Exception: PlaylistModel | Load Thumbnails")
        }
    }

    
    private func loadImages(images: Array<AnyObject>?)
    {
        do
        {
            if (images != nil)
            {
                for value in images!
                {
                    let url = try SSUtils.stringFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONUrl)
                    let nameValue = value[kJSONTitle]
                    let name = ((nameValue as? String) != nil) ? (nameValue as! String) : ""
                    self.images.append(ThumbnailModel(height: 0, width: 0, url: url, name: name))
                }
            }
        }
        catch _
        {
            ZypeLog.error("Exception: PlaylistModel | Load Images")
        }
    }
}

