//
//  AppViewController.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit

class AppViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
         _ = AlertService.sharedInstance.setViewController(self)
    }
    func alert(_ message:String){
        AlertService.sharedInstance.process(message)
    }
    // Hacking for homtabar tintColor
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func customBarButtonItem(title: String, barButton: UIBarButtonItem, action: String){
        let button: UIButton = UIButton()
        button.setTitle(title, for: UIControlState())
        button.frame = CGRect.init(x: 0, y: 0, width: 75, height: 32)
        button.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.41)
        button.titleLabel!.font = UIFont(name: "Times New Roman", size: 14)
        //button.addTarget(self, action: #selector(self.btnLoginClick), for: UIControlEvents.touchUpInside)
        button.addTarget(self, action: Selector((action)), for: UIControlEvents.touchUpInside)
        barButton.customView = button
    }
}
