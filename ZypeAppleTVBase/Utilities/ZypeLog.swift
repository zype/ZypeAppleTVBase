//
//  ZypeLog.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/7/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class ZypeLog {
    
    static func write(text: String)
    {
        if ZypeAppleTVBase.debug
        {
            NSLog("SDK log: %@", text)
        }
    }
    
    static func error(text: String)
    {
        NSLog("SDK error: %@", text)
        if ZypeAppleTVBase.debug
        {
            abort()
        }
    }
    
    static func assert(condition: Bool, message: String)
    {
        if (condition == false)
        {
            NSLog("SDK assert: %@", message)
            if ZypeAppleTVBase.debug
            {
                abort()
            }
        }
    }

}
