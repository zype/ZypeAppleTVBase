//
//  LoginVC.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 9/21/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

class LoginVC: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var loginFooter: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.configureView()
        self.setupText()
        passwordField.addTarget(self, action: #selector(loginClicked(_:)), for: UIControlEvents.editingDidEnd)
        logoImageView.image = UIImage(named: "Logo")
    }
    
    // MARK: - Setup
    
    func setupText() {
        let pageHeaderText = UserDefaults.standard.object(forKey: kLoginPageHeader)
        if pageHeaderText != nil {
            self.loginTitle.text = pageHeaderText as? String
        }
        let pageFooterText = UserDefaults.standard.object(forKey: kLoginPageFooter)
        if pageFooterText != nil {
            self.loginFooter.text = pageFooterText as? String
        }
        
    }
    
    func configureView() {
        //configure for Dark Mode:
        self.view.backgroundColor = UIColor.black
        
        self.emailField.backgroundColor =  UIColor.init(colorLiteralRed: 191.0, green: 191.0, blue: 231.0, alpha: 0.3)
        
        self.emailField.textColor = UIColor.black
        self.emailField.tintColor = UIColor.green
        self.emailField.keyboardAppearance = UIKeyboardAppearance.dark
        
        self.passwordField.backgroundColor = UIColor.init(colorLiteralRed: 191.0, green: 191.0, blue: 231.0, alpha: 0.3)
        
        self.passwordField.textColor = UIColor.black
        self.passwordField.tintColor = UIColor.green
        self.passwordField.keyboardAppearance = UIKeyboardAppearance.dark
    }
    
    // MARK: - Actions
    
    @IBAction func loginClicked(_ sender: UIButton) {
        if self.emailField.text?.isEmpty == true {
            self.presentAlertWithText("Please enter your Email.")
            return
        }
        if self.passwordField.text?.isEmpty == true {
            self.presentAlertWithText("Please enter your Password.")
            return
        }
        
        resetUser()
        if !(self.emailField.text?.isEmpty)! && !(self.passwordField.text?.isEmpty)! {
            //store inputs in NSUserDefaults. We will be checking them on each app launch
            UserDefaults.standard.set(self.emailField.text!, forKey: kUserEmail)
            UserDefaults.standard.set(self.passwordField.text!, forKey: kUserPassword)
            
            ZypeAppleTVBase.sharedInstance.login(self.emailField.text!, passwd: self.passwordField.text!, completion:{ (loggedIn: Bool, error: NSError?) in
                if error != nil {
                    self.presentAlertWithText("Invalid Login and Password.")
                    return
                }
                
                if loggedIn {
                    UserDefaults.standard.set(true, forKey: kDeviceLinkedStatus)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "kPurchaseCompleted"), object: nil)
                }
                else {
                    UserDefaults.standard.set(false, forKey: kDeviceLinkedStatus)
                    ZypeAppleTVBase.sharedInstance.logOut()
                }
            })
        }
    }
    
    fileprivate func presentAlertWithText(_ message : String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let ignoreAction = UIAlertAction(title: "Ok", style: .cancel) { _ in
            
        }
        alertController.addAction(ignoreAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func resetUser() {
        UserDefaults.standard.set(false, forKey: kDeviceLinkedStatus)
        ZypeAppleTVBase.sharedInstance.logOut()
        
        UserDefaults.standard.removeObject(forKey: kUserEmail)
        UserDefaults.standard.removeObject(forKey: kUserPassword)
        
        let defaults = UserDefaults.standard
        
        if let favorites = defaults.object(forKey: "favoritesViaAPI") as? Bool {
            if favorites {
                let favorites = [String]()
                defaults.set(favorites, forKey: kFavoritesKey)
                defaults.synchronize()
            }
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
    }

}
