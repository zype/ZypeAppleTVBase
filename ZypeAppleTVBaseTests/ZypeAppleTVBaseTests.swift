//
//  ZypeAppleTVBaseTests.swift
//  ZypeAppleTVBaseTests
//
//  Created by Andrey Kasatkin on 5/3/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import XCTest
import ZypeAppleTVBase

let consumerLogin = "d@d.com"
let consumerPassword = "d"

// @TODO need another solution here
// shouldn't use a real appKey
let settings = SettingsModel(appKey: "use-a-app-key", apiDomain: "https://api.zype.com", tokenDomain: "https://admin.stg-sigma.zype.com")

class ZypeAppleTVBaseTests: XCTestCase {
    
    
    var waitingCount = 0;
    
    override func setUp() {
        super.setUp()
        waitingCount = 1
        ZypeAppleTVBase.debug = true
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        while (waitingCount != 0)
        {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate:NSDate(timeIntervalSinceReferenceDate:0.1))
        }
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func endTest()
    {
        XCTAssertTrue(NSThread.isMainThread())
        waitingCount = waitingCount - 1
    }
    
    func initLib(complition:() -> Void)
    {
        ZypeAppleTVBase.sharedInstance.reset()
        ZypeAppleTVBase.sharedInstance.initialize(settings, completion:{(error) in
            XCTAssertNil(error)
            complition()
        })
    }
    
    /*
    func login(complition:() -> Void)
    {
        initLib ({ () -> Void in
            ZypeAppleTVBase.sharedInstance.login(consumerLogin, passwd: consumerPassword, completion: { (logedIn, error) -> Void in
                XCTAssertNil(error)
                XCTAssertTrue(logedIn)
                complition()
            })
        })
    }*/
    
    func videos(complition:(videos: Array<VideoModel>?)->Void)
    {
        initLib { () -> Void in
            ZypeAppleTVBase.sharedInstance.getVideos({ (videos, error) -> Void in
                XCTAssertNil(error)
                XCTAssertNotNil(videos)
                XCTAssertFalse(videos!.isEmpty)
                complition(videos: videos)
            })
        }
    }
    
    
    func testInitialize()
    {
        initLib ({ () -> Void in
            //            let a = ZypeAppleTVBase.sharedInstance.getPlaylists()
            //            a?.first?.getVideos({ (videos, error) -> Void in
            //
            //            })
            self.endTest()
        })
    }
    
    func testInitializeIncorrectApiKey()
    {
        ZypeAppleTVBase.sharedInstance.reset()
        ZypeAppleTVBase.sharedInstance.initialize(SettingsModel(clientID: "1", secret: "2", appKey: "3"), loadCategories: true,
                                          completion:{ (error) -> Void in
                                            XCTAssertNotNil(error)
                                            XCTAssertEqual(error?.code, kErrorServiceError)
                                            self.endTest()
        })
    }
    
    func testNotInitiolized()
    {
        ZypeAppleTVBase.sharedInstance.reset()
        ZypeAppleTVBase.sharedInstance.getVideos ({ (videos, error) -> Void in
            XCTAssertNil(videos)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.code, kErrorSDKNotInitialized)
            self.endTest()
        })
    }
    
    func testLogin()
    {
       /* login{
            self.endTest()
        }*/
    }
    
    func testNotLoggedInFavorite()
    {
        videos { (videos) -> Void in
            ZypeAppleTVBase.sharedInstance.setFavorite(videos!.first!, shouldSet: true, completion: { (success, error) -> Void in
                XCTAssertNotNil(error)
                XCTAssertFalse(success)
                XCTAssertEqual(error?.code, kErrorConsumerNotLoggedIn)
                self.endTest()
            })
        }
    }
    
    func testIncorrectLogin()
    {
        initLib ({ () -> Void in
            ZypeAppleTVBase.sharedInstance.login(consumerLogin + "a", passwd: consumerPassword, completion: { (logedIn, error) -> Void in
                XCTAssertNotNil(error)
                XCTAssertFalse(logedIn)
                XCTAssertTrue(error?.code == kErrorIncorrectLoginParameters)
                self.endTest()
            })
        })
    }
    
   /* func testCreateConsumer()
    {
        initLib { () -> Void in
            ZypeAppleTVBase.sharedInstance.createConsumer(ConsumerModel(name: "q", email: "q@q.q", password: "q"), completion: { (success, error) -> Void in
                XCTAssertNil(error)
                XCTAssertTrue(success)
                self.endTest()
            })
        }
    }*/
    
    func testMultiQuery()
    {
        waitingCount = 4
        initLib ({ () -> Void in
            ZypeAppleTVBase.sharedInstance.getVideos({ (videos, error) -> Void in
                XCTAssertNil(error)
                XCTAssertNotNil(videos)
                XCTAssertFalse(videos!.isEmpty)
                self.endTest()
            })
            ZypeAppleTVBase.sharedInstance.getPlaylists(completion: { (playlists, error) -> Void in
                XCTAssertNil(error)
                XCTAssertNotNil(playlists)
                ZypeAppleTVBase.sharedInstance.retrieveVideosInPlaylist(QueryRetrieveVideosInPlaylistModel(playlist: playlists!.first!), completion: { (videos, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertNotNil(videos)
                    if videos != nil {
                        XCTAssertFalse(videos!.isEmpty)
                    }
                    ZypeAppleTVBase.sharedInstance.getVideos({ (videos, error) -> Void in
                        XCTAssertNil(error)
                        XCTAssertNotNil(videos)
                        XCTAssertFalse(videos!.isEmpty)
                        self.endTest()
                    })
                })
            })
            ZypeAppleTVBase.sharedInstance.getZobjectTypes(completion: { (objectTypes, error) -> Void in
                XCTAssertNil(error)
                XCTAssertTrue(objectTypes!.count > 0)
                ZypeAppleTVBase.sharedInstance.getZobjects(QueryZobjectsModel(objectType: objectTypes!.first), completion: { (objects, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertTrue(objects!.count > 0)
                    self.endTest()
                })
            })
            ZypeAppleTVBase.sharedInstance.getVideos({ (videos, error) -> Void in
                XCTAssertNil(error)
                XCTAssertNotNil(videos)
                XCTAssertFalse(videos!.isEmpty)
                self.endTest()
            })
        })
    }
    
    func testZobjectTypes()
    {
        initLib {
            ZypeAppleTVBase.sharedInstance.getZobjectTypes(completion: { (objectTypes, error) -> Void in
                XCTAssertNil(error)
                XCTAssertTrue(objectTypes!.count > 0)
                self.endTest()
            })
        }
    }
    
    func testZobjects()
    {
        initLib {
            let type = QueryZobjectsModel()
            type.zobjectType = "top_playlists"
            ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: { (objects, error) -> Void in
                let playlistID = objects?.first?.getStringValue("playlistid")
                XCTAssertFalse(playlistID!.isEmpty)
                XCTAssertNil(error)
                XCTAssertTrue(objects!.count > 0)
                self.endTest()
            })
        }
    }
    
    func testZobjectsFromType()
    {
       /* initLib {
            ZypeAppleTVBase.sharedInstance.getZobjectTypes(completion: { (objectTypes, error) -> Void in
                objectTypes?.first?.getZobjects({ (zobjects, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertTrue(zobjects!.count > 0)
                    self.endTest()
                })
            })
        }*/
    }
    
    func testSubscriptions()
    {
        initLib { () -> Void in
            ZypeAppleTVBase.sharedInstance.getSubscriptions(completion: { (subscriptions, error) -> Void in
                XCTAssertNil(error)
                self.endTest()
            })
        }
    }
    
    /*
    func testCreateSubscriptions()
    {
        login { () -> Void in
            ZypeAppleTVBase.sharedInstance.createSubscription("yearlyplan", completion: { (subscription, error) -> Void in
                XCTAssertNil(error)
                XCTAssertNotNil(subscription)
                self.endTest()
            })
        }
    }*/
    
    func testGetStream()
    {
      /*  login { () -> Void in
            ZypeAppleTVBase.sharedInstance.getVideos({ (videos, error) -> Void in
                ZypeAppleTVBase.sharedInstance.getVideoObject(videos!.first!, type: VideoUrlType.kVimeoHls, completion: { (url, error) -> Void in
                    XCTAssertNil(error)
                    self.endTest()
                })
            })
        }*/
    }
    
    func testPlaylists()
    {
        initLib { () -> Void in
            ZypeAppleTVBase.sharedInstance.getPlaylists(completion: { (playlists, error) -> Void in
                XCTAssertNil(error)
                XCTAssertNotNil(playlists)
                if playlists != nil {
                    XCTAssertFalse(playlists!.isEmpty)
                }
                self.endTest()
            })
        }
    }
    
    func testRetrieveVideosInPlaylist()
    {
        initLib { () -> Void in
            ZypeAppleTVBase.sharedInstance.getPlaylists(completion: { (playlists, error) -> Void in
                ZypeAppleTVBase.sharedInstance.retrieveVideosInPlaylist(QueryRetrieveVideosInPlaylistModel(playlist: playlists!.first!), completion: { (videos, error) -> Void in
                    XCTAssertNil(error)
                    XCTAssertNotNil(videos)
                    if videos != nil {
                        XCTAssertFalse(videos!.isEmpty)
                    }
                    self.endTest()
                })
            })
        }
    }
    
    func testPlaylistsFromCategory()
    {
       /* ZypeAppleTVBase.sharedInstance.reset()
        ZypeAppleTVBase.sharedInstance.initialize (loadCategories: true,
                                           completion:{ (error) -> Void in
                                            let cat = ZypeAppleTVBase.sharedInstance.getStoredCategories()?.first
                                            cat?.valuesArray?.first?.getPlaylists({ (playlists, error) -> Void in
                                                self.endTest()
                                            })
        })*/
    }
    
    //    func testGetURl()
    //    {
    //        login { () -> Void in
    //            ZypeAppleTVBase.sharedInstance.getVideos({ (videos, error) -> Void in
    //                ZypeAppleTVBase.sharedInstance.getVideoObject(videos!.first!, type: VideoUrlType.kVimeoHls, completion: { (url, error) -> Void in
    //
    //                })
    //            })
    //        }
    //    }
    
}

