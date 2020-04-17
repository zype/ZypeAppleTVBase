//
//  ZypeLog.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/7/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

open class ZypeLog {
    
    public static func write(_ text: String)
    {
        if ZypeAppleTVBase.debug
        {
            NSLog("SDK log: %@", text)
        }
    }
    
    public static func error(_ text: String)
    {
        NSLog("SDK error: %@", text)
        if ZypeAppleTVBase.debug
        {
            NSLog("Abort.. SDK log: %@", text)
            //abort()
        }
    }
    
    public static func assert(_ condition: Bool, message: String)
    {
        if (condition == false)
        {
            NSLog("SDK assert: %@", message)
            if ZypeAppleTVBase.debug
            {
               // abort()
            }
        }
    }

}
