//
//  ZypeLog.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/7/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

public class ZypeLog {
    
    public static func write(text: String)
    {
        if ZypeAppleTVBase.debug
        {
            NSLog("SDK log: %@", text)
        }
    }
    
    public static func error(text: String)
    {
        NSLog("SDK error: %@", text)
        if ZypeAppleTVBase.debug
        {
            NSLog("Abort.. SDK log: %@", text)
            //abort()
        }
    }
    
    public static func assert(condition: Bool, message: String)
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
