//
//  CheckingViewController.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//  code complete

import UIKit
import Crashlytics

class CheckingViewController: AppViewController,AppServiceDelegate{
    // Mark Properties
    @IBOutlet weak var ProgressLablel: UILabel!
    @IBOutlet weak var ProgressChecking: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startProcessChecking()
    }
    // Mark : AppServiceDeleage
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        
        switch identifier {
        case "AuthenticationService.identifyUser.forceRefeshToken.Success":
            onIdentifyUserSuccess()
            break
        case "AuthenticationService.identifyUser.forceRefeshToken.Failure":
            onIdentifyUserFailure()
            break
        default: break
        }
    }
    // Mark : onServiceCallback
    func onIdentifyUserSuccess(){
        finishProcessRefehsingToken()
        self.performSegue(withIdentifier: "sequeShowContainer", sender: self)
    }
    func onIdentifyUserFailure(){
        finishProcessRefehsingToken()
        self.performSegue(withIdentifier: "sequeShowLogin", sender: self)
    }
    func startProcessChecking(){
        _ = AuthenticationService.sharedInstance.setViewController(self)
        startProcessCheckingConnectionInternet()
    }
    func startProcessCheckingConnectionInternet(){
        self.ProgressChecking.progress = 0.0
        self.ProgressLablel.text = AppConstants.MESSAGE_CHECKING_INTENERT
        let time = DispatchTime.now() + Double(Int64(0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            if !ValidateService.sharedInstance.hasInternet(){
                self.alert(ValidateService.sharedInstance.getLastMessage())
            }else{
                self.startProcessIdentifyingAndAuthenticatingUser()
            }
            
        }
    }
    func finishProcessCheckingConnectionInternet(){
        self.ProgressChecking.progress = 0.2
    }
    func startProcessIdentifyingAndAuthenticatingUser(){
        self.ProgressLablel.text = AppConstants.MESSAGE_AUTHENTICATING_USER
        finishProcessCheckingConnectionInternet()
        let time = DispatchTime.now() + Double(Int64(0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC) // 1
        let time2 = DispatchTime.now() + Double(Int64(0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)// 2
        DispatchQueue.main.asyncAfter(deadline: time2) {
            
            //get setting
            AuthenticationService.sharedInstance.registerCallback(self).settings()
            
            if ValidateService.sharedInstance.hasToken(){
                DispatchQueue.main.asyncAfter(deadline: time) {
                    // We have some change with this rule
                    // It always refeshes token when the app is restart
                    //self.ProgressChecking.progress = 0.7
                    self.startProcessRefehsingToken()
                    
                    AuthenticationService.sharedInstance.registerCallback(self).identifyUser(forceRefeshToken:true)
                    
                    if ValidateService.sharedInstance.isExpiredToken(SharedPreferencesService.sharedInstance.token!){
                        
                    }else{
                        // Go to homeController
                    }
                }
            }else{
                DispatchQueue.main.asyncAfter(deadline: time) {
                    //self.finishProcessChecking()
                    self.startProcessLogin()
                }
            }
        }
        
    }
    func finishProcessIdentifyingAndAuthenticatingUser(){
        self.ProgressChecking.progress = 0.7
    }
    func startProcessRefehsingToken(){
        self.ProgressLablel.text = AppConstants.MESSAGE_RERESING_TOKEN
        finishProcessIdentifyingAndAuthenticatingUser()
    }
    func finishProcessRefehsingToken(){
        finishProcessChecking()
    }
    func startProcessLogin(){
        //finishProcessCheckingConnectionInternet()
        self.performSegue(withIdentifier: "sequeShowLogin", sender: self)
    }
    func finishProcessLogin(){
        finishProcessChecking()
    }
    func finishProcessChecking(){
        finishProcessIdentifyingAndAuthenticatingUser()
        self.ProgressChecking.progress = 1
    }
}
