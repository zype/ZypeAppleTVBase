//
//  DeviceLinkingVC.swift
//  ReedTaylorYoga
//
//  Created by Andrey Kasatkin on 5/31/16.
//  Copyright © 2016 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class DeviceLinkingVC: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var deviceLinkingUrl: String?
    var timer = Timer()
    lazy var deviceString = ZypeAppSettings.sharedInstance.deviceId()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (deviceLinkingUrl != nil) {
            firstLineLabel .text = "From your computer or mobile device, go to \(deviceLinkingUrl!)"
        }
        UIButton.appearance().setTitleColor(UIColor.darkGray, for: UIControlState())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ZypeAppleTVBase.sharedInstance.createDevicePin(deviceString, completion:{(devicepPin: String?, error: NSError?) in
            DispatchQueue.main.async(execute: {
                self.activityIndicator.stopAnimating()
                self.pinLabel.text = devicepPin
                self.startTimer()
            })
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    // MARK: - Device Linking Methods
    
    fileprivate func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target:self, selector: #selector(DeviceLinkingVC.checkDeviceStatus), userInfo: nil, repeats: true)
    }
    
    func checkDeviceStatus(){
        ZypeAppleTVBase.sharedInstance.getLinkedStatus(deviceString, completion: {(status: Bool?, pin: String?, error: NSError?) in
            if status == true {
                UserDefaults.standard.set(true, forKey: kDeviceLinkedStatus)
                ZypeUtilities.loginConsumerToGetToken(self.deviceString, pin: pin)
                self.dismiss(animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(false, forKey: kDeviceLinkedStatus)
                ZypeAppleTVBase.sharedInstance.logOut()
            }
        })
    }
    
    // MARK: - Actions
    
    @IBAction func browseContentButtonClicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "kPurchaseCompleted"), object: nil)
    }
}
