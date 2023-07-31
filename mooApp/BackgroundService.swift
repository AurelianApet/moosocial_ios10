//
//  BackgroundService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

open class BackgroundService : NSObject,AppServiceDelegate {
    // Mark: Singleton
    var timerNotification:Timer?
    let timeInterval:TimeInterval = 1.0
    var timerRefeshToken:Timer?
    var timeIntervalRefeshToken:TimeInterval?
    class var sharedInstance : BackgroundService {
        struct Singleton {
            static let instance = BackgroundService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    func updateNotification(_ timer:Timer) {
        backgroundThread(0.0, background: {
            // Your background function here
            NotificationService.sharedInstance.me()
        })

    }
    func refeshToken(_ timer:Timer){
        backgroundThread(0.0, background: {
                AuthenticationService.sharedInstance.registerCallback(self).identifyUser(forceRefeshToken:true)
        })
    }
    func startUpdateNotifcation(){
        if timerNotification == nil{
                    timerNotification = Timer(timeInterval: AppConfigService.sharedInstance.getTimeRefeshForNonGCM(), target: self, selector: #selector(BackgroundService.updateNotification(_:)), userInfo: nil, repeats: true)
           
            RunLoop.current.add(timerNotification!, forMode: RunLoopMode.commonModes)
        }
        
    }
    func endUpdateNotifcation(){
        if timerNotification != nil{
             timerNotification?.invalidate()
        }
       
    }
    func startRefeshToken(){
        if timerRefeshToken == nil{
            
            let timeExpireIn = Double((SharedPreferencesService.sharedInstance.token?.expires_in)!)
            
            if timeExpireIn > 0.0 {
                timerRefeshToken = Timer(timeInterval: timeExpireIn! - 30, target: self, selector: #selector(BackgroundService.refeshToken(_:)), userInfo: nil, repeats: true)
                
                RunLoop.current.add(timerRefeshToken!, forMode: RunLoopMode.commonModes)
            }
            
        }
    }
    func endRefeshToken(){
        if timerRefeshToken != nil{
            timerRefeshToken?.invalidate()
        }
    }
    func backgroundThread(_ delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {

        
        //DispatchQueue.global(priority: Int(DispatchQoS.QoSClass.userInitiated.rawValue)).async {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            if(background != nil){ background!(); }
            
            let popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                if(completion != nil){ completion!(); }
            }
        }
    }
    func start(){
        if !AppConfigService.sharedInstance.isEnableGCM(){
            startUpdateNotifcation()
        }else{
            NotificationService.sharedInstance.me()
        }
        startRefeshToken()
    }
    func end(){
        if !AppConfigService.sharedInstance.isEnableGCM(){
            endUpdateNotifcation()
        }
        endRefeshToken()
    }
    // Mark : AppServiceDeleage
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        
        switch identifier {
        case "AuthenticationService.identifyUser.forceRefeshToken.Success":
            
            break
        case "AuthenticationService.identifyUser.forceRefeshToken.Failure":
            
            break
        default: break
        }
    }
}
