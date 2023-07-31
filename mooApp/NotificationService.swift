//
//  NotificationService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit
import Alamofire
open class NotificationService : AppService {
    // Mark: Properties
    var notification:[NotificationModel] = []
    var notificationController: NotificationsViewController?
    var homeTabBarController: HomeTabBarViewController?
    //let api = AppConfigService.sharedInstance.apiSetting
    // Mark: init
    override init() {
        super.init()
    }
    // Mark: Singleton
    class var sharedInstance : NotificationService {
        struct Singleton {
            static let instance = NotificationService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    // Mark: process
    /*
    * Get all notifcation of user
    */
    func show(_ filter:String="all"){
        //let api = AppConfigService.sharedInstance.apiSetting
        self.dispatch("NotificationService.before.showRequest")
        AlamofireService.sharedInstance.privateSession!.request( api!["URL_LIST_NOTIFICATION","hasToken"]+"&filter="+filter,method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    //break
                    // JSON is NSARRAY
                    
                    
                    if let json = JSON as? [Any] {
                        self.notification = []
                        if json.count > 0 {
                            for case let  item as [String : Any] in json{
                                self.notification.append(NotificationModel(json:item)!)
                            }
                        }else{
                            
                            // Result is empty
                            //AlertService.sharedInstance.process(AppConstants.MESSAGE_NO_RESULT_FOUND,titleAllert:AppConstants.ALERT_DIALOG_TITLE_MESSAGE)
                        }
                        
                        self.dispatch("NotificationService.show.Success",data: self.notification as AnyObject?)
                        /*
                        if(self.notificationController != nil){
                            self.notificationController!.itemNotification = self.notification
                            self.notificationController!.tableView.reloadData()
                        }
                        */
                    }else{
                        if let _ = JSON as? [String:String]{
                            self.dispatch("NotificationService.show.Success",data: nil)
                        }else{
                            print("Something wrong - json must be NSARRAY for requrest " + self.api!["URL_LIST_NOTIFICATION","hasToken"],JSON)
                            
                        }
                   }
                    break
                    
                    
                    
                case .failure(let error):
           
                   
                    if let statusCode = response.response?.statusCode  {
                        if statusCode == 404 {
                            self.dispatch("NotificationService.show.Success",data: nil)
                        
                        }else{
                            if let data = response.data {
                                
                                if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                                    AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                                    print("\(error)")
                                }
                                print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                                
                            }
                        }
                    }
                    
                    
                }
        }

    }
    func me(){
        AlamofireService.sharedInstance.privateSession!.request( api!["URL_GET_NOTIFICATION_COUNT","hasToken"],method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):

                
                   
                    if self.homeTabBarController != nil{
                        var count:Int = 0
                       
                        if let val = JSON as? [String:Any]{
                            if let countNotification = val["count_notification"] as? String
                            {
                                self.updateNotifcationBadge(Int(countNotification)!)
                                count += Int(countNotification)!
                            }
                            if let countConvercation = val["count_conversation"] as? String
                            {
                                
                                self.updateMessageBadge(Int(countConvercation)!)
                                //count += countConvercation
                            }
                        }
                        
                        self.updateApplicationBadge(count)
                    }
                    
                    
                    break
                    
                    
                    
                case .failure(let error):
                    
                    if let data = response.data {
                        
                        if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                            AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                            print("\(error)")
                        }
                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                        
                    }
                    
                }
        }
    }
    func updateNotifcationBadge(_ count:Int){
        if self.homeTabBarController != nil{
            if count > 0{
                self.homeTabBarController?.tabBar.items![1].badgeValue = "\(count)"
            }else{
                self.homeTabBarController?.tabBar.items![1].badgeValue = nil            }
            
        }
    }
    func updateMessageBadge(_ count:Int){
        if self.homeTabBarController != nil{
            if count > 0{
                self.homeTabBarController?.tabBar.items![2].badgeValue = "\(count)"
            }else{
                self.homeTabBarController?.tabBar.items![2].badgeValue = nil            }
            
        }
    }
    func updateApplicationBadge(_ count:Int){
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    func clear(){
    
        AlamofireService.sharedInstance.privateSession!.request( api!["URL_GET_NOTIFICATION_CLEAR","hasToken"],method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    self.me()
                    self.show()
                    break
                case .failure(let error):
                    
                    if let data = response.data {
                        print(error)
                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                        
                    }
                    
                }
        }
    }
    func remove(_ id:String){
        AlamofireService.sharedInstance.privateSession!.request(api!["URL_POST_DELETE_NOTIFICATION","hasToken"],method:.post,parameters:["id":id],encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    // JSON is NSARRAY
                    self.me()
                    break
                    
                    
                    
                case .failure(let error):
                    
                    if let data = response.data {
                        
                        if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                            AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                            print("\(error)")
                        }
                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                        
                    }
                    
                }
        }
        
    
    }
    func markAsRead(_ id:String,status:Bool){
        
        let uri = (api!["URL_POST_MARK_READ_UNREAD_NOTIFICATION","hasToken"]).replacingOccurrences(of: ":id",with:id);
        var unread = 0;
        if status {
            unread = 1;
        }
        AlamofireService.sharedInstance.privateSession!.request(uri,method:.post,parameters:["unread":unread],encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    // JSON is NSARRAY
                    self.me()
                    break
                    
                    
                    
                case .failure(let error):
                    
                    if let data = response.data {
                        
                        if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                            AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                            print("\(error)")
                        }
                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                        
                    }
                    
                }
        }
    }
    
    func data(_ page:String="1"){
        //let api = AppConfigService.sharedInstance.apiSetting
        self.dispatch("NotificationService.before.showRequest")
        AlamofireService.sharedInstance.privateSession!.request( api!["URL_LIST_NOTIFICATION","hasToken"]+"&page="+page,method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    //break
                    // JSON is NSARRAY
                    
                    
                    if let json = JSON as? [Any] {
                        self.notification = []
                        if json.count > 0 {
                            for case let  item as [String : Any] in json{
                                self.notification.append(NotificationModel(json:item)!)
                            }
                        }else{
                            
                            // Result is empty
                            //AlertService.sharedInstance.process(AppConstants.MESSAGE_NO_RESULT_FOUND,titleAllert:AppConstants.ALERT_DIALOG_TITLE_MESSAGE)
                            
                        }
                        
                        //self.dispatch("NotificationService.show.Success",data: self.notification as AnyObject?)
                        
                         if(self.notificationController != nil){
                            if(self.notification.count > 0) {
                                self.notificationController!.itemNotification += self.notification
                                self.notificationController!.tableView.reloadData()
                            }
                            else {
                                self.notificationController!.btViewMore.isHidden = true
                            }
                            
                         }
                        
                    }else{
                        if let _ = JSON as? [String:String]{
                            self.dispatch("NotificationService.show.Success",data: nil)
                        }else{
                            print("Something wrong - json must be NSARRAY for requrest " + self.api!["URL_LIST_NOTIFICATION","hasToken"],JSON)
                            
                        }
                        
                    }
                    break
                    
                    
                    
                case .failure(let error):
                    
                    self.notificationController!.btViewMore.isHidden = true
                    
                    if let statusCode = response.response?.statusCode  {
                        if statusCode == 404 {
                            //self.dispatch("NotificationService.show.Success",data: nil)
                            
                        }else{
                            if let data = response.data {
                                print("\(error)")
                                /*if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                                    AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                                    print("\(error)")
                                }*/
                                print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                                
                            }
                        }
                    }
                    
                    
                }
        }
        
    }
}
