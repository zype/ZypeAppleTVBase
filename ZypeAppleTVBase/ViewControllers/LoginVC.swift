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

    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var loginFooter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.configureView()
        self.setupText()
        passwordField.addTarget(self, action: #selector(loginClicked(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
    }

    func setupText() {
        let pageHeaderText = NSUserDefaults.standardUserDefaults().objectForKey(kLoginPageHeader)
        if (pageHeaderText != nil) {
           self.loginTitle.text = (pageHeaderText as! String)
        }
        let pageFooterText = NSUserDefaults.standardUserDefaults().objectForKey(kLoginPageFooter)
        if (pageFooterText != nil) {
            self.loginFooter.text = (pageFooterText as! String)
        }

    }
    
    func configureView() {
        //configure for Dark Mode:
        self.view.backgroundColor = UIColor.blackColor()
        
        self.emailField.backgroundColor =  UIColor.init(colorLiteralRed: 191.0, green: 191.0, blue: 231.0, alpha: 0.3)

        self.emailField.textColor = UIColor.blackColor()
        self.emailField.tintColor = UIColor.greenColor()
        self.emailField.keyboardAppearance = UIKeyboardAppearance.Dark
        
        self.passwordField.backgroundColor = UIColor.init(colorLiteralRed: 191.0, green: 191.0, blue: 231.0, alpha: 0.3)
        
        self.passwordField.textColor = UIColor.blackColor()
        self.passwordField.tintColor = UIColor.greenColor()
        self.passwordField.keyboardAppearance = UIKeyboardAppearance.Dark
    }
    
    @IBAction func loginClicked(sender: UIButton) {
        if ((self.emailField.text?.isEmpty) == true) {
            self.presentAlertWithText("Please enter your Email.")
            return
        }
        if ((self.passwordField.text?.isEmpty) == true) {
            self.presentAlertWithText("Please enter your Password.")
            return
        }
        
        if (!(self.emailField.text?.isEmpty)! && !(self.passwordField.text?.isEmpty)!) {
            //store inputs in NSUserDefaults. We will be checking them on each app launch
            NSUserDefaults.standardUserDefaults().setObject(self.emailField.text!, forKey: kUserEmail)
            NSUserDefaults.standardUserDefaults().setObject(self.passwordField.text!, forKey: kUserPassword)
            
            ZypeAppleTVBase.sharedInstance.login(self.emailField.text!, passwd: self.passwordField.text!, completion:{ (logedIn: Bool, error: NSError?) in
                print(logedIn)
                if (error != nil) {
                    self.presentAlertWithText("Invalid Login and Password.")
                    return
                }
                
                if (logedIn){
                     NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDeviceLinkedStatus)
                      NSNotificationCenter.defaultCenter().postNotificationName(kZypeReloadScreenNotification, object: nil)
                    self.dismissViewControllerAnimated(true, completion: {_ in})
                } else {
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDeviceLinkedStatus)
                    ZypeAppleTVBase.sharedInstance.logOut()
                }
                
            })
        }
    }
    
    
    func presentAlertWithText(message : String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let ignoreAction = UIAlertAction(title: "Ok", style: .Cancel) { _ in
            
        }
        alertController.addAction(ignoreAction)

        self.presentViewController(alertController, animated: true, completion: nil)

    }
}
