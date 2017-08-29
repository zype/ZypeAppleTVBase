//
//  RegisterVC.swift
//  ZypeAppleTVBase
//
//  Created by Eric Chang on 7/20/17.
//  Copyright © 2017 Zype. All rights reserved.
//

import Foundation

class RegisterVC: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.image = UIImage(named: "Logo")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUserLogin()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "kPurchaseCompelted"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Setup
    
    fileprivate func setupUserLogin() {
        if ZypeUtilities.isDeviceLinked() {
            setupLoggedInUser()
        }
        else {
            setupLoggedOutUser()
        }
    }
    
    fileprivate func setupLoggedInUser() {
        let defaults = UserDefaults.standard
        let kEmail = defaults.object(forKey: kUserEmail)
        guard let email = kEmail else { return }
        
        let loggedInString = NSMutableAttributedString(string: "Logged in as: \(String(describing: email))", attributes: nil)
        let buttonRange = (loggedInString.string as NSString).range(of: "\(String(describing: email))")
        loggedInString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 38.0), range: buttonRange)
        
        accountLabel.attributedText = loggedInString
        accountLabel.textAlignment = .center
        
        loginButton.isHidden = true
    }
    
    fileprivate func setupLoggedOutUser() {
        accountLabel.attributedText = NSMutableAttributedString(string: "Already have an account?")
        loginButton.isHidden = false
    }
    
    // MARK: - Actions
    
    @IBAction func onRegister(_ sender: UIButton) {
        guard self.validateFields() else { return }
        
        let consumer = ConsumerModel(name: emailTextField.text!,
                                     email: emailTextField.text!,
                                     password: passwordTextField.text!)
        
        ZypeAppleTVBase.sharedInstance.createConsumer(consumer) { (success, error) in
            
            if success {
                //store inputs in NSUserDefaults. We will be checking them on each app launch
                UserDefaults.standard.set(self.emailTextField.text!, forKey: kUserEmail)
                UserDefaults.standard.set(self.passwordTextField.text!, forKey: kUserPassword)
                
                ZypeAppleTVBase.sharedInstance.login(consumer.emailString, passwd: consumer.passwordString, completion: { (loggedIn, error) in
                    if loggedIn {
                        UserDefaults.standard.set(true, forKey: kDeviceLinkedStatus)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
                        
                        let presentingViewController = self.presentingViewController
                        self.dismiss(animated: false, completion: {
                            presentingViewController!.dismiss(animated: true)
                        })
                    }
                    else {
                        if let error = error?.localizedDescription {
                            self.presentAlertWithText(error)
                        }
                    }
                })
            }
            // could not create consumer
            else {
                if let error = error?.localizedDescription {
                    self.presentAlertWithText(error)
                }
                else {
                    self.presentAlertWithText("Oops! Something went wrong. Could not register.")
                }
            }
        }
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPurchased),
                                               name: NSNotification.Name(rawValue: "kPurchaseCompleted"),
                                               object: nil)
        ZypeUtilities.presentLoginMethodVC(self)
    }
    
    func onPurchased() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Utilities
    
    fileprivate func validateFields() -> Bool {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            guard !email.isEmpty else {
                self.presentAlertWithText("Please enter your email.")
                return false
            }
            guard isValid(email: email) else {
                self.presentAlertWithText("Please enter a valid email")
                return false
            }
            guard !password.isEmpty else {
                self.presentAlertWithText("Please create a password.")
                return false
            }
            
            return true
        }
        print("Field not valid")
        return false
    }
    
    fileprivate func presentAlertWithText(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let ignoreAction = UIAlertAction(title: "Ok", style: .cancel) { _ in }
        
        alertController.addAction(ignoreAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func isValid(email:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
}
