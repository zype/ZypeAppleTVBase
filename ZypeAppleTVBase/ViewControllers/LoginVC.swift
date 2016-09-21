//
//  LoginVC.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 9/21/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

class LoginVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!


    @IBAction func loginClicked(sender: UIButton) {
        print ("login clicked")
        if (!(self.emailField.text?.isEmpty)! && !(self.passwordField.text?.isEmpty)!) {
            ZypeAppleTVBase.sharedInstance.login(self.emailField.text!, passwd: self.passwordField.text!, completion:{ (logedIn: Bool, error: NSError?) in
                print(logedIn)
                if (logedIn){
                    self.dismissViewControllerAnimated(true, completion: {_ in})
                }
                
            })
        }
        
    }
}
