//
//  AlertService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//
import UIKit
import Foundation
open class AlertService : NSObject {
    // Mark : Propeties
    var presentViewController : UIViewController?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    // Mark : setter and getter 
    func setViewController(_ viewController:UIViewController)->AlertService{
        presentViewController = viewController
        return self
    }
    
    // Mark: Singleton
    class var sharedInstance : AlertService {
        struct Singleton {
            static let instance = AlertService()
        }
        // Return singleton instance
        return Singleton.instance
    }
    // Mark process 
    func registerCurrentView(_ view:UIViewController)-> AlertService{
        presentViewController = view
        return self
    }
    func process(_ message:String, titleAllert:String? = String(), titleAction:String?=String()){
         appDelegate.alert(message,titleAllert: titleAllert,titleAction: titleAction)
        /*
        if titleAllert == String(){
            titleAllert = AppConstants.ALERT_DIALOG_TITLE
        }
        if titleAction == String(){
            titleAction = AppConstants.ALERT_DIALOG_BUTTON
        }
        if (presentViewController != nil) {
            let alert = UIAlertController(title: titleAllert, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: titleAction, style: UIAlertActionStyle.Default, handler: nil))
            presentViewController!.presentViewController(alert, animated: true, completion: nil)
            
            
        }
        */
    }
}
