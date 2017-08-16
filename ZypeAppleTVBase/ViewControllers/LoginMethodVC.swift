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
    
    // MARK: - Actions
    
    @IBAction func onEmail(_ sender: UIButton) {
        ZypeUtilities.presentLoginVC(self)
    }

    @IBAction func onDevice(_ sender: UIButton) {
        ZypeUtilities.presentFrameworkVC(self)
        // ZypeUtilities.presentDeviceLinkingVC(self, deviceLinkingUrl: <#T##String#>)
        // deviceLinkingUrl needs z-object
        // app returns empty z-object
    }

}
