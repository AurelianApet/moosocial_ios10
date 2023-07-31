//
//  MessageService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
import Alamofire
open class MessageService : AppService {
    // Mark: Properties
    var message:[MessageModel] = []
    var messageController: MessagesViewController?
    //let api = AppConfigService.sharedInstance.apiSetting
    // Mark: init
    override init() {
        super.init()
    }
    // Mark: Singleton
    class var sharedInstance : MessageService {
        struct Singleton {
            static let instance = MessageService()
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
        self.dispatch("MessageService.before.showRequest")
        AlamofireService.sharedInstance.privateSession!.request(api!["URL_LIST_MESSEAGE","hasToken"]+"&filter="+filter, method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):

                  
                     if let json = JSON as? [Any] {
                        self.message = []
                        if json.count > 0 {
                            for case let  item as [String : Any] in json{
                                self.message.append(MessageModel(json:item)!)
                            }
                        }else{
                            // Result is empty
                            //AlertService.sharedInstance.process(AppConstants.MESSAGE_NO_RESULT_FOUND,titleAllert:AppConstants.ALERT_DIALOG_TITLE_MESSAGE)
                        }
                        self.dispatch("MessageService.show.Success",data: self.message as AnyObject?)
                        /*
                        if(self.messageController != nil){
                            self.messageController!.itemMessage = self.message
                            self.messageController!.tableView.reloadData()
                        }
                        */
                    }else{
                        if let _ = JSON as? [String:String]{
                            self.dispatch("MessageService.show.Success",data: nil)
                        }else{
                          print("Something wrong - json must be NSARRAY for requrest " + self.api!["URL_LIST_MESSEAGE","hasToken"])
                        }
                      
                    }
                    break
                    
                    
                    
                case .failure(let error):
                    
                    if let statusCode = response.response?.statusCode  {
                        if statusCode == 404 {
                            self.dispatch("MessageService.show.Success",data: nil)
                            
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
    
    func data(_ page:String="1"){
        //let api = AppConfigService.sharedInstance.apiSetting
        self.dispatch("MessageService.before.showRequest")
        AlamofireService.sharedInstance.privateSession!.request(api!["URL_LIST_MESSEAGE","hasToken"]+"&filter=all"+"&page="+page, method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    
                    if let json = JSON as? [Any] {
                        self.message = []
                        if json.count > 0 {
                            for case let  item as [String : Any] in json{
                                self.message.append(MessageModel(json:item)!)
                            }
                        }else{
                            // Result is empty
                            //AlertService.sharedInstance.process(AppConstants.MESSAGE_NO_RESULT_FOUND,titleAllert:AppConstants.ALERT_DIALOG_TITLE_MESSAGE)
                        }
                        //self.dispatch("MessageService.show.Success",data: self.message as AnyObject?)
                        
                         if(self.messageController != nil){
                         self.messageController!.itemMessage += self.message
                         self.messageController!.tableView.reloadData()
                         }
                        
                    }else{print("2")
                        if let _ = JSON as? [String:String]{
                            self.dispatch("MessageService.show.Success",data: nil)
                        }else{
                            print("Something wrong - json must be NSARRAY for requrest " + self.api!["URL_LIST_MESSEAGE","hasToken"])
                        }
                        
                    }
                    break
                    
                    
                    
                case .failure(let error):
                    self.messageController!.btViewMore.isHidden = true
                    print("\(error)")
                    break
                    /*if let statusCode = response.response?.statusCode  {
                        if statusCode == 404 {
                            //self.dispatch("MessageService.show.Success",data: nil)
                            
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
                    }*/
                    
                    
                    
                }
        }
    }
    
    func markAsRead(_ id:String,status:Bool){
        
        let uri = (api!["URL_POST_MARK_READ_UNREAD_MESSAGE","hasToken"]).replacingOccurrences(of: ":id",with:id);
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

    
}
