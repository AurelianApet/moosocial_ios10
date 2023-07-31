//
//  MessageModel.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation

struct MessageModel {
    var id:Int?
    var from:Any?
    var to:Any?
    var created_time:String?
    var updated_time:String?
    var subject:String?
    var message:String?
    var link:String?
    var unread:Bool = true
    var object:Any?
}
extension MessageModel{
    init?(json:[String:Any]){
        guard let id=json["id"] as? String,
            let created_time = json["created_time"] as? String,
            let updated_time = json["updated_time"] as? String,
            let link = json["link"] as? String,
            let unread = json["unread"] as? Bool
            else{
                return nil
        }
        self.id = Int(id)
        self.created_time = created_time
        self.updated_time = updated_time
        self.subject = json["subject"] as? String
        self.message = json["message"] as? String
        self.unread = unread
        self.link = link
        self.from = json["from"]
        self.to = json["to"]
        self.object = json["object"]
    }
}
