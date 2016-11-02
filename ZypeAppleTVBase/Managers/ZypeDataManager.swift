//
//  ZypeDataManager.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/8/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class ZypeDataManager : NSObject {

    //private
    private let serviceController: ZypeRESTController

    //public
    internal let cacheManager = ZypeCacheManager()
    private(set) internal var tokenManager = ZypeTokenManager()
    private(set) internal var consumer = ConsumerModel()

    //MARK: initialize
    init(settings: SettingsModel)
    {
        serviceController = ZypeRESTController(settings: settings)
        super.init()
    }

    func initializeLoadCategories(load: Bool, error: NSError?, completion: (error: NSError?) ->Void)
    {
        if load == false || error != nil
        {
            completion(error: error)
        }
        else
        {
            self.getCategories(QueryCategoriesModel(), completion: { (_, error) -> Void in
                completion(error: error)
            })
        }
    }

    func initializeLoadPlaylists(load: Bool, error: NSError?, completion: (error: NSError?) ->Void)
    {
        if load == false || error != nil
        {
            completion(error: error)
        }
        else
        {
            self.getPlaylists(QueryPlaylistsModel(), completion: { (_, error) -> Void in
                completion(error: error)
            })
        }
    }

    //MARK: Login
    func logOut()
    {
        tokenManager.tokenModel.reset()
        consumer.reset()
        cacheManager.resetConsumer()
    }

    func login(username: String, passwd: String, completion:(logedIn: Bool, error: NSError?) -> Void)
    {
        serviceController.getTokenWithUsername(username, withPassword: passwd, withCompletion: {(data, error) -> Void in
            if (error != nil)
            {
                self.loginCompletion(false, error: error, completion: completion)
            }
            else if (data == nil)
            {
                self.loginCompletion(false, error: NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: nil), completion: completion)
            }
            else
            {
                let error = self.tokenManager.setLoginAccessTokenData(data!)
                if (error != nil)
                {
                    self.loginCompletion(false, error: error, completion: completion)
                }
                else
                {
                    self.loadConsumer(completion)
                }
            }
       })
    }
    
    func login(deviceId: String, pin: String, completion:(logedIn: Bool, error: NSError?) -> Void)
    {
        serviceController.getTokenWithDeviceId(deviceId, withPin: pin, withCompletion:{(data, error) -> Void in
            if (error != nil)
            {
                self.loginCompletion(false, error: error, completion: completion)
            }
            else if (data == nil)
            {
                self.loginCompletion(false, error: NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: nil), completion: completion)
            }
            else
            {
                let error = self.tokenManager.setLoginAccessTokenData(data!)
                if (error != nil)
                {
                    self.loginCompletion(false, error: error, completion: completion)
                }
                else
                {
                    self.loadConsumer(completion)
                }
            }
        })
    }

    func loadConsumer(completion:(success: Bool, error: NSError?) -> Void)
    {
        if (tokenManager.tokenModel.refreshToken.isEmpty)
        {
            self.loginCompletion(false, error: nil, completion:completion)
            return
        }
        tokenManager.accessToken({ (token) -> Void in
            self.serviceController.getConsumerIdWithToken(token, completion: { (jsonDic, error) -> Void in
                do
                {
                    let idString = try SSUtils.stringFromDictionary(jsonDic, key: kJSONResourceOwnerId)
                    if (idString.isEmpty == false)
                    {
                        self.serviceController.getConsumerInformationWithID(token, consumerId: idString, withCompletion: { (jsonDic, error) -> Void in
                            do
                            {
                                if (jsonDic != nil)
                                {
                                    let response = jsonDic![kJSONResponse] as! Dictionary <String, AnyObject>?
                                    if (response != nil)
                                    {
                                        let emailString = try SSUtils.stringFromDictionary(response, key: kJSONEmail)
                                        let nameString = try SSUtils.stringFromDictionary(response, key: kJSONName)
                                        dispatch_sync(dispatch_get_main_queue(),{
                                            self.consumer.setData(idString, email: emailString, name: nameString)
                                        })
                                        self.loginCompletion(self.consumer.isLoggedIn, error: error, completion: completion)
                                        return
                                    }
                                }
                            }
                            catch _
                            {
                            }
                            self.loginCompletion(false, error: error, completion: completion)
                        })
                        return
                    }
                }
                catch _
                {
                }
                self.loginCompletion(false, error: error, completion: completion)
            })
        }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }

    func createConsumer(consumer: ConsumerModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        self.serviceController.createConsumer(consumer) { (jsonDic, err) -> Void in
            var success = false
            var error = err
            if error == nil && jsonDic != nil
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    success = true
                }
            }
            dispatch_sync(dispatch_get_main_queue(),{
                completion(success: success, error: err)
            })
        }
    }

    //MARK: Categories
    func getCategories(queryModel: QueryCategoriesModel,  toArray: Array<CategoryModel> = Array<CategoryModel>(),
        completion:(categories: Array<CategoryModel>, error: NSError?) -> Void)
    {
        var toArr = toArray
        serviceController.getCategories(queryModel, completion: { (jsonDic, error) -> Void in
            var err = error
            if (jsonDic != nil && error == nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    let data = response as? Array <AnyObject>
                    if (data != nil)
                    {
                        for value in data!
                        {
                            let category  = CategoryModel(fromJson: value as! Dictionary<String, AnyObject>)
                            toArr.append(category)
                        }
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.getCategories(queryModel, toArray: toArr, completion: completion)
                        return
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(categories: self.cacheManager.synchronizeCategories(toArr)!, error: err)
            })
        })
    }

    //MARK: Videos
    func getVideos(queryModel: QueryVideosModel, returnArray: Array<VideoModel> = Array<VideoModel>(),
        completion:((videos: Array<VideoModel>?, error: NSError?) -> Void))
    {
        var returnArr = returnArray
        serviceController.getVideos(queryModel, completion:{ (jsonDic, error) -> Void in
           var err = error
            if jsonDic != nil
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let videos = self.jsonToVideosArrayPrivate(jsonDic)
                    if (videos != nil)
                    {
                        returnArr.appendContentsOf(videos!)
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.getVideos(queryModel, returnArray: returnArr, completion: completion)
                        return
                    }
                }
            }
            self.videoCompletion(returnArr, error: err, completion:completion)
        })
    }

    //TODO need  add subscriptions and test
    func getVideoObject(video: VideoModel, type: VideoUrlType, completion:(playerObject: VideoObjectModel?, error: NSError?) -> Void)
    {
        ZypeFactory.videoUrl(type, restController: serviceController)?.getVideoObject(video, completion: {(player, error) in
            dispatch_async(dispatch_get_main_queue(), {
                completion(playerObject: player, error: error)
            })
        })
    }

   //MARK: favorites
    func getFavorites(completion:(favorites: Array<FavoriteModel>?, error: NSError?) -> Void)
    {
        completion(favorites: cacheManager.favorites, error: nil)
    }

    func setFavorite(object: BaseModel, shouldSet: Bool, completion:(success: Bool, error: NSError?) -> Void)
    {
        let favoriteObject: FavoriteModel? = shouldSet == true ? nil : cacheManager.findFavoteForObject(object)
        if (shouldSet == false && favoriteObject == nil)
        {
            completion(success: false, error: NSError(domain: kErrorDomaine, code: kErrorItemNotInFavorites, userInfo: nil))
            return
        }
        tokenManager.accessToken({ (token) -> Void in
            if (shouldSet == true)
            {
                self.favoriteVideo(token, object: object, completion: completion)
            }
            else
            {
                self.unfavoriteVideo(token, favoriteObject: favoriteObject!, completion: completion)
            }
         }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }

    //MARK: MyLibrary
    func getMyLibrary(completion:(favorites: Array<FavoriteModel>?, error: NSError?) -> Void)
    {
        tokenManager.accessToken({ (token) -> Void in
            self.serviceController.getMyLibrary(token, consumerId: self.consumer.ID, completion:{ (jsonDic, error) -> Void in
                var err = error
                if jsonDic != nil
                {
                    err = self.isServiceError(jsonDic!)
                    if (err == nil)
                    {
                        print(jsonDic)
                    }
                }
            })
        
            }, update: serviceController.refreshAccessTokenWithCompletionHandler)
        
       
    }
    
    
    //MARK: zobjects
    func getZobjectTypes(queryModel: QueryZobjectTypesModel, toArray: Array<ZobjectTypeModel> = Array<ZobjectTypeModel>(),
        completion:(objectTypes: Array<ZobjectTypeModel>, error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.getZobjectTypes(queryModel) { (jsonDic, error) -> Void in
           var err = error
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    for value in response as! Array<AnyObject>
                    {
                        toArr.append(ZobjectTypeModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                }
            }
            if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
            {
                queryModel.page = queryModel.page + 1
                self.getZobjectTypes(queryModel, toArray: toArr, completion: completion)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(objectTypes: self.cacheManager.synchronizeZobjectTypes(toArr)!, error: err)
            })
        }
    }

    func getZobjects(queryModel: QueryZobjectsModel, toArray: Array<ZobjectModel> = Array<ZobjectModel>(),
        completion:(objects: Array<ZobjectModel>, error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.getZobjects(queryModel, completion: {(jsonDic, error) -> Void in
           var err = error
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    for value in response as! Array<AnyObject>
                    {
                        toArr.append(ZobjectModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                }
            }
            if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
            {
                queryModel.page = queryModel.page + 1
                self.getZobjects(queryModel, toArray: toArr, completion: completion)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(objects: self.cacheManager.synchronizeZobjects(toArr)!, error: err)
            })
        })
    }

    //MARK: Subscriptions
    //TODO need convert subscription from json to model
    func getSubscriptions(queryModel: QuerySubscriptionsModel, toArray: Array<SubscriptionModel> = Array<SubscriptionModel>(),
        completion:(subscriptions: Array<SubscriptionModel>, error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.getSubscriptions(queryModel, completion: { (jsonDic, error) -> Void in
           var err = error
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    for value in response as! Array<AnyObject>
                    {
                        toArr.append(SubscriptionModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.getSubscriptions(queryModel, toArray: toArr, completion: completion)
                        return
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(subscriptions: toArr, error: err)
            })
        })
    }

    //TODO need api not work
    func createSubscription(planID: String, completion:(subscription: SubscriptionModel?, error: NSError?) -> Void)
    {
        self.serviceController.createSubscription(self.consumer.ID, planID: planID, completion:{ (jsonDic, error) -> Void in
            var err = error
            var subscription: SubscriptionModel?
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    subscription = SubscriptionModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(subscription: subscription, error: err)
            })
        })
    }

    func retrieveSubscription(subscription: SubscriptionModel, completion:(subscription: SubscriptionModel?, error: NSError?) -> Void)
    {
        self.serviceController.retrieveSubscription(subscription.ID, completion:{ (jsonDic, error) -> Void in
            var err = error
            var subscription: SubscriptionModel?
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    subscription = SubscriptionModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(subscription: subscription, error: err)
            })
        })
    }

    func updateSubscription(planID: String, completion:(subscription: SubscriptionModel?, error: NSError?) -> Void)
    {
        self.serviceController.updateSubscription(self.consumer.ID, planID: planID, completion: {(jsonDic, error) -> Void in
            var err = error
            var subscription: SubscriptionModel?
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    subscription = SubscriptionModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(subscription: subscription, error: err)
            })
        })
    }

    func removeSubscription(subscription: SubscriptionModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        self.serviceController.removeSubscription(subscription.ID, completion: { (jsonDic, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completion(success: false, error: error)
            })
        })
    }

    //MARK: play list
    func getPlaylists(queryModel: QueryPlaylistsModel, toArray: Array<PlaylistModel> = Array<PlaylistModel>(),
        completion:(playlists: Array<PlaylistModel>, error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.getPlaylists(queryModel, completion: { (jsonDic, error) -> Void in
            var err = error
            if jsonDic != nil
            {
                err = self.isServiceError(jsonDic!)
                if err == nil
                {
                    for value in jsonDic![kJSONResponse] as! Array<AnyObject>
                    {
                        toArr.append(PlaylistModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.getPlaylists(queryModel, toArray: toArr, completion: completion)
                        return
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(playlists: self.cacheManager.synchronizePlaylists(toArr), error: err)
            })
        })
    }

    func retrieveVideosInPlaylist(queryModel: QueryRetrieveVideosInPlaylistModel, toArray: Array<VideoModel> = Array<VideoModel>(),
        completion:(videos: Array<VideoModel>?, error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.retrieveVideosInPlaylist(queryModel, completion: { (jsonDic, error) -> Void in
            var err = error
            if jsonDic != nil
            {
                err = self.isServiceError(jsonDic!)
                if err == nil
                {
                    let videos = self.jsonToVideosArrayPrivate(jsonDic)
                    if (videos != nil)
                    {
                        toArr.appendContentsOf(videos!)
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.retrieveVideosInPlaylist(queryModel, toArray: toArr, completion: completion)
                        return
                    }
                }
            }
            self.videoCompletion(toArr, error: err, completion:completion)
        })
    }
    
    //MARK: App Info
    func loadAppInfo(queryModel: QueryBaseModel, completion:(backgroundUrl: String?, error: NSError?) -> Void)
    {
        self.serviceController.getAppInfo(queryModel, completion: { (jsonDic, let error) -> Void in
            if jsonDic != nil {
                let response = jsonDic![kJSONResponse] as! NSDictionary
                let backgroundImageUrl = response .valueForKey("background_url") as? String
                
                completion(backgroundUrl: backgroundImageUrl, error:nil)
                
            }
        })
    }
    
    //MARK: Device Linking
    func getDevicePin(device: String, completion:(devicepPin: String?, error: NSError?) -> Void)
    {
        self.serviceController.getDevicePin(device, completion: { (jsonDic, let error) -> Void in
            if jsonDic != nil {
                let response = jsonDic![kJSONResponse] as! NSDictionary
                let devicepPin = response .valueForKey("pin") as? String
                
                completion(devicepPin: devicepPin, error:nil)
                
            }
        })
    }

    func getLinkedStatus(device: String, completion:(linked: Bool?,pin: String?, error: NSError?) -> Void)
    {
        self.serviceController.getLinkedStatus(device, completion: { (jsonDic, let error) -> Void in
            if jsonDic != nil {
                let message = jsonDic!["message"] as? String
                if (message == "Invalid Device Pin.") {
                    completion(linked: false, pin:nil, error:nil)
                } else {
                let response = jsonDic![kJSONResponse] as? NSDictionary
                let linkedStatus = response!.valueForKey("linked") as? Bool
                let pin = response!.valueForKey("pin") as? String
                    completion(linked: linkedStatus, pin: pin, error:nil)
                }
                
            }
        })
    }
    
    //MARK: Token
    func getToken(completion:(token: String?, error: NSError?) -> Void)
    {
        tokenManager.accessToken({ (token) -> Void in
            completion(token: token, error: nil)
            }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }
    
    //MARK: Private
    private func loadFavorites(page: Int = kApiFirstPage)
    {
        tokenManager.accessToken({ (token) -> Void in
            self.serviceController.getFavorites(token, consumerId: self.consumer.ID, page: page, completion: { (jsonDic, error) -> Void in
                let favorites = self.jsonToFavoriteArrayPrivate(jsonDic)
                if (favorites != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.cacheManager.addFavoriteVideos(favorites)
                        
                    })
                } else {
                    
                }
                if (self.isLastPage(jsonDic) == false)
                {
                    self.loadFavorites(page + 1)
                }
            })
            }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }
    
    private func favoriteVideo(token: String, object: BaseModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        self.serviceController.favoriteObject(token, consumerId: self.consumer.ID, objectID: object.ID, completion: { (jsonDic, error) -> Void in
            var err = error
            let favorites = self.jsonToFavoriteArrayPrivate(jsonDic)
            let success = favorites != nil && favorites?.isEmpty == false && favorites?.first?.objectID == object.ID
            if (success == false && jsonDic != nil)
            {
                 err = NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: jsonDic as? Dictionary<String, String>)
            }
            dispatch_async(dispatch_get_main_queue(), {
                if (success == true)
                {
                    self.cacheManager.addFavoriteVideos(favorites)
                }
                completion(success: success, error: err)
            })
        })
    }

    private func unfavoriteVideo(token: String, favoriteObject: FavoriteModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        self.serviceController.unfavoriteObject(token, consumerId: self.consumer.ID, favoriteID: favoriteObject.ID, completion: { (statusCode, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (statusCode == kHTTPCodeNoContent)
                {
                    self.cacheManager.removeFromFavorites(favoriteObject)
                }
                completion(success: statusCode == kHTTPCodeNoContent, error: error)
            })
        })
    }

    private func loginCompletion(logedIn: Bool, error: NSError?, completion:(logedIn: Bool, error: NSError?) -> Void)
    {
        dispatch_async(dispatch_get_main_queue(),{
            completion(logedIn: logedIn, error: error)
        })
        if (logedIn == true)
        {
            loadFavorites()
        }
    }

    private func videoCompletion(videos: Array<VideoModel>?, error: NSError? ,completion:(videos: Array<VideoModel>?, error: NSError?) -> Void)
    {
        dispatch_async(dispatch_get_main_queue(), {
            completion(videos: self.cacheManager.synchronizeVideos(videos), error: error)
        })
    }

    private func jsonToFavoriteArrayPrivate(jsonDic: Dictionary<String, AnyObject>?) -> Array<FavoriteModel>?
    {
        if (jsonDic != nil)
        {
            let response = jsonDic![kJSONResponse]
            if (response != nil)
            {
                var array = Array<FavoriteModel>()
                if (response as? Array<AnyObject> == nil)
                {
                     array.append(FavoriteModel(json: response as! Dictionary<String, AnyObject>))
                }
                else
                {
                    for value in response as! Array<AnyObject>
                    {
                        array.append(FavoriteModel(json: value as! Dictionary<String, AnyObject>))
                    }
                }
                return array
            }
        }
        return nil
    }

    private func jsonToVideosArrayPrivate(jsonDic: Dictionary<String, AnyObject>?) -> Array<VideoModel>?
    {
        if (jsonDic != nil)
        {
            let response = jsonDic![kJSONResponse]
            if (response != nil)
            {
                var dataArray = Array<VideoModel>()
                for value in (response as? Array<AnyObject>)!
                {
                    dataArray.append(VideoModel(fromJson: (value as? Dictionary<String, AnyObject>)!))
                }
                return dataArray
            }
        }
        return nil
    }

    private func isServiceError(jsonDic: Dictionary<String, AnyObject>, shouldContainsField: String = kJSONResponse) -> NSError?
    {
        let response = jsonDic[shouldContainsField]
        if (response != nil)
        {
            return nil
        }
        return NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: jsonDic as? Dictionary<String, String>)
    }

    private func isLastPage(jsonDic:Dictionary<String, AnyObject>?) -> Bool
    {
        do
        {
            if (jsonDic != nil)
            {
                let pagination = jsonDic![kJSONPagination]
                if ((pagination) != nil)
                {
                    let pages = try SSUtils.intagerFromDictionary(pagination as? Dictionary<String, AnyObject>, key: kJSONPages)
                    let current = try SSUtils.intagerFromDictionary(pagination as? Dictionary<String, AnyObject>, key: kJSONCurrent)
                    if (current < pages)
                    {
                        return false
                    }
                }
            }
        }
        catch _
        {
        }
        return true
    }

}
