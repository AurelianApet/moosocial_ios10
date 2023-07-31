//
//  FriendService.swift
//  mooApp
//
//  Created by duy on 5/5/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import Alamofire
open class FriendService : AppService {
    // Mark: Properties
    var friends:[FriendModel] = []
    var messageController: MessagesViewController?
    private var mentions=[SZUserMention]()
    //let api = AppConfigService.sharedInstance.apiSetting
    // Mark: init
    override init() {
        super.init()
    }
    // Mark: Singleton
    class var sharedInstance : FriendService {
        struct Singleton {
            static let instance = FriendService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    func getMentions(_ filter:String = "",_ refesh:Bool = false)->[SZUserMention]?{
        if refesh{
            getRaw()
            return [SZUserMention]()
        }else{
            if mentions.isEmpty{
                getRaw()
                return [SZUserMention]()
            }
        }
        if filter != "" {
            return (mentions.filter({ (user) -> Bool in
                let tmp: NSString = (user as SZUserMention).szMentionName as NSString
                let range = tmp.range(of: filter, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            }))
        }
        return mentions
    }
    // Mark: process
    /*
     * Get all notifcation of user
     */
    func getRaw(){
        //let api = AppConfigService.sharedInstance.apiSetting
        self.dispatch("MessageService.before.showRequest")
        AlamofireService.sharedInstance.privateSession!.request(api!["URL_FRIEND_LIST","hasToken"], method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    if let json = JSON as? [String : Any] {
                        self.friends = []
                        self.mentions = [SZUserMention]()
                        if let totalFriend = json["totalFriendCount"] as? Int{
                            if totalFriend   > 0 {
                                if let data = json["friends"] as? [Any] {
                                    for case let  item as [String:Any] in data {
                                        let friend = FriendModel(json:item)
                                        let mention = SZUserMention()
                                        self.friends.append(friend!)
                                        // For mention 
                                        mention.szMentionName = (friend?.name!)!
                                        mention.szMentionId = (friend?.id)!
                                        if let photo = friend?.image?["200_square"] {
                                            mention.szMentionAvatar = photo
                                        }
                                        self.mentions.append(mention)
                                    }
                                }
                            }else{
                                // Result is empty
                                //AlertService.sharedInstance.process(AppConstants.MESSAGE_NO_RESULT_FOUND,titleAllert:AppConstants.ALERT_DIALOG_TITLE_MESSAGE)
                            }
                            self.dispatch("FriendService.get.Success",data: self.friends as AnyObject?)
                        }
                        
                        /*
                         if(self.messageController != nil){
                         self.messageController!.itemMessage = self.message
                         self.messageController!.tableView.reloadData()
                         }
                         */
                    }else{
                        if let _ = JSON as? [String:String]{
                            self.dispatch("FriendService.get.Success",data: nil)
                        }else{
                            print("Something wrong - json must be NSARRAY for requrest " + self.api!["URL_LIST_MESSEAGE","hasToken"])
                        }
                        
                    }
                    break
                    
                    
                    
                case .failure(let error):
                    
                    if let statusCode = response.response?.statusCode  {
                        if statusCode == 404 {
                            self.dispatch("FriendService.get.Success",data: nil)
                            
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
}

class SZUserMention: SZCreateMentionProtocol {
    var szMentionId:Int = 0
    var szMentionName: String = ""
    var szMentionAvatar:String = ""
    var szMentionRange: NSRange = NSMakeRange(0, 0)
}
