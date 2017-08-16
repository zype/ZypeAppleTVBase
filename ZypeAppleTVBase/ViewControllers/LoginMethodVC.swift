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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func onEmail(_ sender: UIButton) {
        ZypeUtilities.presentLoginVC(self)
    }

    @IBAction func onDevice(_ sender: UIButton) {
        // empty z-object
    }

}
