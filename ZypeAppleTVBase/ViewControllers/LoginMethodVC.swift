//
//  LoginMethodVC.swift
//  Pods
//
//  Created by Eric Chang on 8/8/17.
//
//

import UIKit

class LoginMethodVC: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var deviceButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logoImageView.image = UIImage(named: "Logo")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "kPurchaseCompleted"), object: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func onEmail(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPurchased),
                                               name: NSNotification.Name(rawValue: "kPurchaseCompleted"),
                                               object: nil)
        ZypeUtilities.presentLoginVC(self)
    }

    @IBAction func onDevice(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPurchased),
                                               name: NSNotification.Name(rawValue: "kPurchaseCompleted"),
                                               object: nil)
        ZypeUtilities.presentFrameworkVC(self)
        
        //TODO: -
        // ZypeUtilities.presentDeviceLinkingVC(self, deviceLinkingUrl: <#T##String#>)
        // deviceLinkingUrl needs z-object
        // app returns empty z-object
    }
    
    func onPurchased() {
        self.dismiss(animated: true, completion: nil)
    }

}
