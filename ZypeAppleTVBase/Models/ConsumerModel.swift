//
//  ConsumerModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/14/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class ConsumerModel: NSObject {
    
    fileprivate (set) open var ID:String = ""
    fileprivate (set) open var emailString:String = ""
    fileprivate (set) open var nameString:String = ""
    fileprivate (set) internal var passwordString: String = ""
    fileprivate (set) open var subscriptionCount: Int = 0
    fileprivate (set) open var subscriptionIds: Array<AnyObject> = []
    
    public init(name: String = "", email: String = "", password: String = "", subscription: Int = 0)
    {
        super.init()
        self.nameString = name
        self.emailString = email
        self.passwordString = password
        self.subscriptionCount = subscription
    }
    
    open var isLoggedIn: Bool {
        return ID.isEmpty == false
    }
    
    func setData(_ consumerId: String, email: String, name: String, subscription: Int, subscriptions: Array<AnyObject>)
    {
        ID = consumerId
        emailString = email
        nameString = name
        subscriptionCount = subscription
        subscriptionIds = subscriptions
    }
    
    func reset()
    {
        ID = ""
        emailString = ""
        nameString = ""
        subscriptionCount = 0
        subscriptionIds = []
    }
    
}

