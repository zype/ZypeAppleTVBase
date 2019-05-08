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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var tosCheckbox: UIButton!
    @IBOutlet weak var tosLabel: UILabel!
    
    static let validateTosKey = "validate_tos"
    var tosChecked: Bool = true
    var checkedBoxImage: UIImage?
    var uncheckedBoxImage: UIImage?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shouldValidateTos() {
            setupTosCheckbox()
        } else {
            hideTos()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onRegister(_ sender: UIButton) {
        guard self.validateFields() else { return }
        
        let consumer = ConsumerModel(name: emailTextField.text!,
                                     email: emailTextField.text!,
                                     password: passwordTextField.text!)
        
        ZypeAppleTVBase.sharedInstance.createConsumer(consumer) { (success, error) in
            
            if success {
                ZypeAppleTVBase.sharedInstance.login(consumer.emailString, passwd: consumer.passwordString, completion: { (loggedIn, error) in
                    if loggedIn {
                        UserDefaults.standard.set(consumer.emailString, forKey: kUserEmail)
                        UserDefaults.standard.set(consumer.passwordString, forKey: kUserPassword)
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
    
    @IBAction func onTosClick(_ sender: UIButton) {
        if tosChecked {
            sender.setBackgroundImage(uncheckedBoxImage, for: .normal)
            sender.setBackgroundImage(uncheckedBoxImage, for: .highlighted)
            sender.setBackgroundImage(uncheckedBoxImage, for: .selected)
            tosChecked = false
        } else {
            sender.setBackgroundImage(checkedBoxImage, for: .normal)
            sender.setBackgroundImage(checkedBoxImage, for: .highlighted)
            sender.setBackgroundImage(checkedBoxImage, for: .selected)
            tosChecked = true
        }
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
            if shouldValidateTos() && !tosChecked {
                self.presentAlertWithText("You must agree with the terms of service in order to proceed.")
                return false
            }
            
            return true
        }
        print("Field no valid")
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
    
    fileprivate func shouldValidateTos() -> Bool {
        if UserDefaults.standard.bool(forKey: RegisterVC.validateTosKey) {
            return true
        }
        return false
    }
    
    fileprivate func setupTosCheckbox() -> Void {        
        let podBundle = Bundle(for: ZypeAppleTVBase.self)
        guard let bundleURL = podBundle.url(forResource: "ZypeAppleTVBaseResources", withExtension: "bundle") else {
            hideTos()
            return
        }
        guard let bundle = Bundle(url: bundleURL) else {
            hideTos()
            return
        }
        guard let checkedBox = UIImage(named: "checkedBox.png", in: bundle, compatibleWith: nil),
            let uncheckedBox = UIImage(named: "uncheckedBox.png", in: bundle, compatibleWith: nil) else {
                hideTos()
                return
        }
        
        checkedBoxImage = checkedBox
        uncheckedBoxImage = uncheckedBox
        tosCheckbox.setBackgroundImage(checkedBoxImage, for: .normal)
        tosCheckbox.setBackgroundImage(checkedBoxImage, for: .selected)
        tosCheckbox.setBackgroundImage(checkedBoxImage, for: .highlighted)
        tosChecked = true

        showTos()
    }
    
    fileprivate func showTos() -> Void {
        tosCheckbox.isHidden = false
        tosLabel.isHidden = false
    }
    
    fileprivate func hideTos() -> Void {
        tosCheckbox.isHidden = true
        tosLabel.isHidden = true
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        ZypeUtilities.presentLoginVC(self, true)
    }
}
