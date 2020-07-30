//
//  ZypeUserAgentBuilder.swift
//  ZypeAppleTVBase
//
//  Created by Anish Kumar on 21/04/20.
//  Copyright © 2020 Zype. All rights reserved.
//

import Foundation
import UIKit

struct UserAgent {
    public static let product = "Mozilla/5.0"
    public static let platform = "AppleWebKit/605.1.15"
    public static let platformDetails = "(KHTML, like Gecko)"
    public static let uaBitMobile = "Mobile/15E148"
}

@objc public class ZypeUserAgentBuilder: NSObject {
    // User agent components
    fileprivate var product: String
    fileprivate var systemInfo: String
    fileprivate var platform: String
    fileprivate var platformDetails: String
    fileprivate var appVersion: String
    fileprivate var uaBitMobile: String
    
    init(product: String, systemInfo: String, platform: String, platformDetails: String, uaBitMobile: String, appVersion: String) {
        self.product = product
        self.systemInfo = systemInfo
        self.platform = platform
        self.platformDetails = platformDetails
        self.uaBitMobile = uaBitMobile
        self.appVersion = appVersion
    }
    
    @objc public func userAgent() -> String {
        let userAgentItems = [product, systemInfo, platform, platformDetails, uaBitMobile, appVersion]
        return removeEmptyComponentsAndJoin(uaItems: userAgentItems)
    }
    
    @objc public static func buildtUserAgent() -> ZypeUserAgentBuilder {
        return ZypeUserAgentBuilder(product: UserAgent.product, systemInfo: "(\(UIDevice.current.model.replacingOccurrences(of: " ", with: "")),3; CPU tvOS \(UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X)", platform: UserAgent.platform, platformDetails: UserAgent.platformDetails, uaBitMobile: UserAgent.uaBitMobile, appVersion: ZypeUserAgentBuilder.appNameAndVersion())
    }
    
    /// Helper method to remove the empty components from user agent string that contain only whitespaces or are just empty
    private func removeEmptyComponentsAndJoin(uaItems: [String]) -> String {
        return uaItems.filter{ !$0.isEmpty }.joined(separator: " ")
    }
    
    //eg. MyApp/1
    private static func appNameAndVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let name = dictionary["CFBundleName"] as! String
        return "\(name)/\(version)"
    }
}
