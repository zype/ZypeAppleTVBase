//
//  DeviceLinkingVC.swift
//  ReedTaylorYoga
//
//  Created by Andrey Kasatkin on 5/31/16.
//  Copyright © 2016 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class DeviceLinkingVC: UIViewController {

    var deviceLinkingUrl: String?
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var pinLabel: UILabel!
    var timer = NSTimer()
    lazy var deviceString = ZypeAppSettings.sharedInstance.deviceId()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if (deviceLinkingUrl != nil) {
            firstLineLabel .text = "From your computer or mobile device, go to \(deviceLinkingUrl!)"
        }
        UIButton.appearance().setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ZypeAppleTVBase.sharedInstance.createDevicePin(deviceString, completion:{(devicepPin: String?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue(),{
                self.activityIndicator.stopAnimating()
                self.pinLabel.text = devicepPin
                self.startTimer()
            })
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }

    private func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector: #selector(DeviceLinkingVC.checkDeviceStatus), userInfo: nil, repeats: true)
    }
    
     func checkDeviceStatus(){
        ZypeAppleTVBase.sharedInstance.getLinkedStatus(deviceString, completion: {(status: Bool?, error: NSError?) in
            if status == true {
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDeviceLinkedStatus)
                    self.dismissViewControllerAnimated(true, completion: nil)
            }
            dispatch_async(dispatch_get_main_queue(),{
               
            })
        })
    }
    
    @IBAction func browseContentButtonClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {_ in})
    }
}