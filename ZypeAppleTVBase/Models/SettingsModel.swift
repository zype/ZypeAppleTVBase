//
//  SettingsModel.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/26/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//
    
open class SettingsModel: NSObject
{
    //keys
    public let appKey: String
    internal let clientId: String
    internal let clientSecret: String

    //hosts
    internal let apiDomain: String
    internal let tokenDomain: String
    internal let playerDomain: String

    //network
    internal let allowAllCertificates: Bool
    internal let userAgent: String

    public init (clientID: String? = nil,
        secret: String? = nil,
        appKey: String? = nil,
        apiDomain: String? = nil,
        tokenDomain: String? = nil,
        playerDomain: String? = nil,
        allowAllCertificates: Bool = false,
        userAgent: String = "")
    {
        self.clientId = clientID ?? kOAuthClientId
        self.clientSecret = secret ?? kOAuthClientSecret
        self.appKey = appKey ?? kAppKey
        self.apiDomain = apiDomain ?? kApiDomain
        self.tokenDomain = tokenDomain ?? KOAuth_GetTokenDomain
        self.playerDomain = playerDomain ?? kPlayerDomain
        self.allowAllCertificates = allowAllCertificates
        self.userAgent = userAgent
        super.init()
    }

}
