//
//  ShareService.swift
//  mooApp
//
//  Created by tuan on 6/21/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import Alamofire

open class ShareService : AppService {
    var message:String = ""
    var messageText:String = ""
    var share_type:String = ""
    var action:String = ""
    var item_type:String = ""
    var param:String = ""
    var object_id:Int = 0
    var userTaging:[Int] = []
    var friendSuggestion:[Int] = []
    var groupSuggestion:[Int] = []
    var email:String = ""
    var WhatsNewWKController: WhatsNewWKViewController?
    
    // Mark: init
    override init() {
        super.init()
        let title = NSLocalizedString("post_status_processing",comment:"post_status_processing")
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(NSForegroundColorAttributeName,
                                     value: UIColor.gray,
                                     range: NSMakeRange(0,(title as NSString).length))
    }
    
    func setData(share_type:String, object_id:Int, action:String = "", item_type: String = "", param: String = ""){
        self.share_type = share_type
        self.action = action
        self.object_id = object_id
        self.item_type = item_type
        self.param = param
    }
    
    // Mark: Share
    /*
     * Share feed
     */
    func post(){
        var parameters:Parameters = [
            "message":self.message,
            "messageText":self.messageText,
            "share_type":self.share_type,
            "action":self.action,
            "param":self.param,
            "object_id":self.object_id,
            "item_type":self.item_type,
        ]
        if !self.userTaging.isEmpty{
            parameters["userTagging"] = self.userTaging.map(String.init).joined(separator: ",")
        }
        if !self.friendSuggestion.isEmpty{
            parameters["friendSuggestion"] = self.friendSuggestion.map(String.init).joined(separator: ",")
        }
        if !self.groupSuggestion.isEmpty{
            parameters["groupSuggestion"] = self.groupSuggestion.map(String.init).joined(separator: ",")
        }
        if self.email != ""{
            parameters["email"] = self.email
        }
        
        AlamofireService.sharedInstance.privateSession!.request( api!["URL_SHARE_FEED","hasToken"],method:.post,parameters: parameters,encoding:JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    self.WhatsNewWKController?.doRefeshWebview()
                case .failure(let error):
                    self.dispatch("AuthenticationService.identifyUser.forceLogin.Failure")
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

