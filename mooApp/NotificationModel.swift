//
//  NotificationModel.swift
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
struct NotificationModel{
    var id:String?
    var from:Any?
    var to:Any?
    var created_time:String?
    var updated_time:String?
    var title:String?
    var link:String?
    var unread:Bool = true
    var object:Any?
}
extension NotificationModel{
    init?(json:[String:Any]){
    
        guard let id=json["id"] as? String,
              let created_time = json["created_time"] as? String,
              let updated_time = json["updated_time"] as? String,
              let link = json["link"] as? String,
              let unread = json["unread"] as? Bool
        else{
                return nil
        }
        self.id = id
        self.created_time = created_time
        self.updated_time = updated_time
        self.unread = unread
        self.link = link
        self.from = json["from"]
        self.to = json["to"]
        self.title = json["title"] as? String
        self.object = json["object"]
    }
}
