//
//  LogoutVC.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 10/03/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

public class LogoutVC: UIViewController {

 
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var logoutTitle: UILabel!
    
    @IBOutlet weak var logoutFooter: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        //self.configureView()
        self.setupText()
    }

    func setupText() {
        let pageHeaderText = NSUserDefaults.standardUserDefaults().objectForKey(kLogoutPageHeader)
        if (pageHeaderText != nil) {
           self.logoutTitle.text = pageHeaderText as? String
        }
        let pageFooterText = NSUserDefaults.standardUserDefaults().objectForKey(kLogoutPageFooter)
        if (pageFooterText != nil) {
            self.logoutFooter.text = pageFooterText as? String
        }

    }
    
    @IBAction func logoutClicked(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDeviceLinkedStatus)
        ZypeAppleTVBase.sharedInstance.logOut()
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserEmail)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserPassword)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let favorites = [String]()
        defaults.setObject(favorites, forKey: kFavoritesKey)
        defaults.synchronize()
        
         NSNotificationCenter.defaultCenter().postNotificationName(kZypeReloadScreenNotification, object: nil)
    }
}
