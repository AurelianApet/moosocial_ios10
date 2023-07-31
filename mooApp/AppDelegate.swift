//
//  AppDelegate.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit
import UserNotifications

import Fabric
import Crashlytics

import Firebase
import FirebaseInstanceID
import FirebaseMessaging


import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/global"

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
   


        FirebaseApp.configure()
        AppConfigService.sharedInstance.boot()
        AppConfigService.sharedInstance.makeFontNavaigationIsWhite()
        
        
        

        if AppConfigService.sharedInstance.isEnableGCM(){
            // [START register_for_notifications]
            if #available(iOS 10.0, *) {
                let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_,_ in })
                
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
                // For iOS 10 data message (sent via FCM)
                Messaging.messaging().delegate = self
                
            } else {
                let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
                application.registerUserNotificationSettings(settings)
            }
            
            application.registerForRemoteNotifications()
            
            // [END register_for_notifications]
            //FirebaseApp.configure()
            
            // Add observer for InstanceID token refresh callback.
            NotificationCenter.default.addObserver(self,
                                                             selector: #selector(self.tokenRefreshNotification),
                                                             name: NSNotification.Name.InstanceIDTokenRefresh,
                                                             object: nil)
        }
        
        
        if let options = launchOptions {
            
            if let notification = options[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
 
                if let url = notification["notification_url"] as? String{
                    WebViewService.sharedInstance.pushNotificationURL = url
                     AppConfigService.sharedInstance.openedFromPushNotification()
                }
               
            }
        }
        
        Fabric.with([Crashlytics.self])
        //FirebaseApp.configure()
    
        
        return true
    }
    // [START refresh_token]
    func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            GCMsService.sharedInstance.registrationToken = refreshedToken
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        Messaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(String(describing: error))")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
   
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
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        AppConfigService.sharedInstance.appTimeDidEnterBackgorund = Date().timeIntervalSince1970

    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    }
    func applicationDidBecomeActive(_ application: UIApplication) {

        if AppConfigService.sharedInstance.isEnableGCM(){
            connectToFcm()
        }
        


        if AppConfigService.sharedInstance.isTimeToReset(){
            AppConfigService.sharedInstance.appTimeDidEnterBackgorund = Date().timeIntervalSince1970
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "Checking") as! CheckingViewController
            
            self.window?.rootViewController = initialViewController
        }
        
    }
    // [END connect_gcm_service]
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        BackgroundService.sharedInstance.end()
        if AppConfigService.sharedInstance.isEnableGCM(){
            Messaging.messaging().disconnect()
            print("Disconnected from FCM.")
        }
    }
    
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        
        //GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID,
        //    scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }

    /*
    // [START ack_message_reception]
    func application( _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
            if AppConfigService.sharedInstance.isEnableGCM(){
                print("Message ID: \(userInfo["gcm.message_id"]!)")
                print("%@", userInfo)
                // This works only if the app started the GCM service
               // GCMService.sharedInstance().appDidReceiveMessage(userInfo);
                // Handle the received message
                // [START_EXCLUDE]
                NotificationCenter.default.post(name: Notification.Name(rawValue: messageKey), object: nil,
                    userInfo: userInfo)
                // [END_EXCLUDE]
                if ( application.applicationState == UIApplicationState.inactive || application.applicationState == UIApplicationState.background  )
                {
       
                    //opened from a push notification when the app was on background
                    //AppConfigService.sharedInstance.isOpenedFromPushNotifications=true
                }
            }
            
    }
     */
    func application( _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
            var newData = false
            if AppConfigService.sharedInstance.isEnableGCM(){
                // This works only if the app started the GCM service
                // GCMService.sharedInstance().appDidReceiveMessage(userInfo);
                // Handle the received message
                // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
                // [START_EXCLUDE]
                //NotificationCenter.default.post(name: Notification.Name(rawValue: messageKey), object: nil,
                //    userInfo: userInfo)
                //handler(UIBackgroundFetchResult.noData);
                // [END_EXCLUDE]
               
                if ( application.applicationState == UIApplicationState.inactive || application.applicationState == UIApplicationState.background  )
                {
                    //opened from a push notification when the app was on background
                    //AlertService.sharedInstance.process("opened from a push notification when the app was on background")
                    //AppConfigService.sharedInstance.isOpenedFromPushNotifications=true
                    
                    // Todo redirect here
                    // We have two case
                    // Case 1  : App is ready -> just redirect to whatsnew view
                    // Case 2  : App is not ready -> checking oauth -> redirect to whatsnew
                    
                    if let info = userInfo as? Dictionary<String,AnyObject> {
                        newData = true
                        

                        if let url = info["notification_url"]{
                            WebViewService.sharedInstance.pushNotificationURL = (url as? String)!
                            if AppConfigService.sharedInstance.isOpenedFromPushNotifications{
                                
                                
                                
                            }else{
                                if !AppConfigService.sharedInstance.isTimeToReset(){
                                    AppConfigService.sharedInstance.activeFromPushNotification()
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let containner: ContainerViewController = storyboard.instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
                                    containner.centerViewAction = AppConstants.ACTION_ACTIVE_WEB_ON_WHATS_NEW_FROM_NOTIFICATIONS
                                    getTopViewController().present(containner, animated:true, completion:nil)
                                    NotificationService.sharedInstance.show()
                                    NotificationService.sharedInstance.me()
                                }else{
                                    WebViewService.sharedInstance.isAppCallFromNotificationURLAndTimeToReset = true
                                }
                 
                                
                            }
          
                        }
                        
                    }
                    
                    
                    
                    
                }else{
                   
                    NotificationService.sharedInstance.show()
                    NotificationService.sharedInstance.me()
                    // For broadcast message
                    
                    if let info = userInfo as? Dictionary<String,AnyObject> {
                        //NSLog(info["type"] as! String)
                        if let type = info["type"]{
                            if type as! String == "global" {
                                self.alert(info["message"] as! String,titleAllert:"Message Broadcast")
                            }
                        }
                    }
                }
            }
            
        handler(newData ? .newData : .failed)
        
    }
    // [END ack_message_reception]
    
    func getTopViewController()->UIViewController{
        return topViewControllerWithRootViewController(UIApplication.shared.keyWindow!.rootViewController!)
    }
    func topViewControllerWithRootViewController(_ rootViewController:UIViewController)->UIViewController{
        if rootViewController is UITabBarController{
            let tabBarController = rootViewController as! UITabBarController
            return topViewControllerWithRootViewController(tabBarController.selectedViewController!)
        }
        if rootViewController is UINavigationController{
            let navBarController = rootViewController as! UINavigationController
            return topViewControllerWithRootViewController(navBarController.visibleViewController!)
        }
        if let presentedViewController = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(presentedViewController)
        }
        return rootViewController
    }
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            // Disable GCM
            /*GCMPubSub.sharedInstance().subscribe(withToken: self.registrationToken, topic: subscriptionTopic,
                options: nil, handler: {(error ) -> Void in
                    if (error != nil) {
                        // Treat the "already subscribed" error more gently
                        print("Todo subscribeToTopic: error.code == 3001 not work - need to debug here")
                        /*
                        if error.code == 3001 {
                            print("Already subscribed to \(self.subscriptionTopic)")
                        } else {
                            print("Subscription failed: \(error?.localizedDescription)");
                        }
                        */
                    } else {
                        self.subscribedToTopic = true;
                        //NSLog("Subscribed to \(self.subscriptionTopic)");
                    }
            })
            */
        }
    }
    
    
   
    func alert(_ message:String,titleAllert:String? = String(),titleAction:String?=String()){
        var titleAllert = titleAllert
        var titleAction = titleAction
        if titleAllert == String(){
            titleAllert = AppConstants.ALERT_DIALOG_TITLE
        }
        if titleAction == String(){
            titleAction = AppConstants.ALERT_DIALOG_BUTTON
        }
        if (self.window?.rootViewController != nil) {
            let alert = UIAlertController(title: titleAllert, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: titleAction, style: UIAlertActionStyle.default, handler: nil))
         
              self.getTopViewController().present(alert, animated: true, completion: nil)
           
          
        }
    }
    
    //facebook google login
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        
        return googleDidHandle || facebookDidHandle
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    private func userNotificationCenter(center: UNUserNotificationCenter,
                                willPresentNotification notification: UNNotification,
                                withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@ userNotificationCenter", userInfo)
    }
}

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
    }
    // Receive data message on iOS 10 devices.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("%@ applicationReceivedRemoteMessage", remoteMessage.appData)
    }
}

// [END ios_10_message_handling]
