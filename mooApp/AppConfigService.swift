//
//  AppConfigService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
import UIKit
open class AppConfigService : NSObject {
    var apiSetting:ApiSettings?
    var appConfig=[String:Any]()
    var config = AppConfig()
    var isOpenedFromPushNotifications = false
    var isActivedFromPushNotifications = false
    var linksNotAllowSetTitle=[String]()
    var linksNotAllowSetBackButton=[String]()
    var linksHaveFilter = [String]()
    var nsLinksData=[String:[String:Any]]()
    var baseURL:String?
    var appTimeFinishlauch = Date().timeIntervalSince1970
    var appTimeDidEnterBackgorund = Date().timeIntervalSince1970
    var appTimeToReset:Double = 3600
    // Mark: Singleton
    override init(){
        
        
        super.init()
        self.appConfig = self.loadAppConfig()
        self.detectBaseURL()
        self.apiSetting = ApiSettings(url:getBaseURL())
        self.initLinksNotAllowSetAction()
    }
    
    class var sharedInstance : AppConfigService {
        struct Singleton {
            static let instance = AppConfigService()
        }
        // Return singleton instance
        return Singleton.instance
    }
    
    func boot(){
        
        WebViewService.sharedInstance.modifiedUserAgent(" mooIOS/1.0")
        
    }
    func bootAfterLogin(){
        
         if AppConfigService.sharedInstance.isEnableGCM(){
                GCMsService.sharedInstance.saveTokenToServer(true)
         }
        NotificationService.sharedInstance.me()
 
    }
    func bootAfterLoadingHomeTabBar(){
        //BackgroundService.sharedInstance.start()
    }
    func beforeLogout(){
        GCMsService.sharedInstance.deleteTokenOnServer()
    }
    func loadAppConfig()->[String : Any]{
        if appConfig.isEmpty {
            
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: AppConstants.CONFIG_PATH_FILE_APP!)){
                
                //appConfig = JsonService.sharedInstance.convertToNSDictionary(jsonData)
                appConfig = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String : Any]
            }
        }
        return appConfig
    }
    func getBaseURL()->String{
        return baseURL!
    }
    func getTermOfServiceURL()->String{
        if let list_urls = appConfig["list_urls"] as? [String: Any] {
            return  baseURL! + (list_urls["term_service"] as! String)
        }
        return baseURL!
    }
    func getPrivacyPolicyURL()->String{
        if let list_urls = appConfig["list_urls"] as? [String: Any] {
            return  baseURL! + (list_urls["privacy_policy"] as! String)
        }
        return baseURL!
    }
    func detectBaseURL(){
        if let general = appConfig["general"] as? [String:Any]{
            if let baseURL = general["initialUrl"]{
                self.baseURL = baseURL as? String
            }else{
                self.baseURL = String()
            }
        }
        
    }
    func getApiKey()->String{
        if let general = appConfig["general"] as? [String:Any]{
            if let baseURL = general["apiKey"]{
                return baseURL as! String
            }
        }
        
        
        return String()
    }
    func initLinksNotAllowSetAction(){
        
        for i in 0..<config.webViewWhiteList.count  {
            linksNotAllowSetTitle.append(getBaseURL() +  config.webViewWhiteList[i])
        }

        
        if let menus = appConfig["menus"] as? [String:Any] {
            for (key,_) in menus {
                if let array = menus[key] as? [Any]{
                    for  case let object as [String:Any] in array {
                        let link = getBaseURL() + (object["url"] as! String)
                        linksNotAllowSetTitle.append(link)
                        if let subLinks = object["subLinks"] as? [Any]{
                            linksHaveFilter.append(link)
                            for case let subObject as [String:Any] in subLinks{
                                let subLink = getBaseURL() + (subObject["url"] as! String)
                                linksNotAllowSetTitle.append(subLink)
                                nsLinksData[subLink] = ["title":(object["label"] as! String),"filter":subLinks]
                            }
                            nsLinksData[link] = ["title":(object["label"] as! String),"filter":subLinks]
                        }else{
                            nsLinksData[link] = ["title":(object["label"] as! String),"filter":[]]
                        }
                        if let action = object["action"] as? [String:Any]{
                            nsLinksData[link]?["action"] = action
                        }
                    }
                }
                
            }
        }
        linksNotAllowSetBackButton = linksNotAllowSetTitle
        
        // Hacking for /activities/ajax_browse/everyone","/activities/ajax_browse/friends"
        let activitiesEveryone = getBaseURL() + "/activities/ajax_browse/everyone"
        let activitiesFriends  = getBaseURL() + "/activities/ajax_browse/friends"
        let filter = [["label":"items_whats_new_everyone","url":"/activities/ajax_browse/everyone"],
                      ["label":"items_whats_new_friends_me","url":"/activities/ajax_browse/friends"]]
        

        nsLinksData[activitiesEveryone] = ["title":NSLocalizedString("tabbar_whats_news",comment:"tabbar_whats_news"),"filter":filter]
        nsLinksData[activitiesFriends] = ["title":NSLocalizedString("tabbar_whats_news",comment:"tabbar_whats_news"),"filter":filter]
     
    }
    func isAllowSetTitle(_ forLink:String)-> Bool{
        return !linksNotAllowSetTitle.contains(forLink)
        //return !(nsLinksNotAllowSetTitleDS!.allKeys as! [String]).contains(forLink)
    }
    func isAllowSetBackButton(_ forLink:String)-> Bool{
        return !linksNotAllowSetBackButton.contains(forLink)
    }
    func isHavingFilter(_ forLink:String)-> Bool{
        return linksHaveFilter.contains(forLink)
    }
    func getLinksHaveFilter()->[String]{
        return [String]()
    }
    func isEnableGCM()->Bool{
        if let general = appConfig["general"] as? [String:Any]{
            if let _ = general["apiKey"]{
                return general["enableGCM"] as! Bool
            }
        }
        
        return false
    }
    func makeFontNavaigationIsWhite(){
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 19.0)]
    }
    func openedFromPushNotification(){
        isOpenedFromPushNotifications = true
        isActivedFromPushNotifications = false
    }
    func activeFromPushNotification(){
        isOpenedFromPushNotifications = false
        isActivedFromPushNotifications = true
    }
    func afterImplemitingOnTapFromPushNotification(){
        isOpenedFromPushNotifications = false
        isActivedFromPushNotifications = false
    }
    func isTimeToReset()->Bool{
        return (Date().timeIntervalSince1970 - appTimeDidEnterBackgorund > appTimeToReset)
    }
    func getTimeRefeshForNonGCM()->Double{
        //return 1111.0;
        if let general = appConfig["general"] as? [String:Any]{
            return Double(general["notificationTime"] as! NSNumber );
        }
        return 11.0;
    }
}
