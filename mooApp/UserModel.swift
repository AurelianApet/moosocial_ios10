//
//  UserModel.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation


struct UserModel{
    let id:Int
    var name:String?
    var email:String?
    var avatar:AnyObject?
    //let photo:String?
    var last_login:String?
    var photo_count:Int?
    var friend_count:Int?
    var notification_count:Int?
    var friend_request_count:Int?
    var blog_count:Int?
    var topic_count:Int?
    var conversation_user_count:Int?
    var gender:String?
    var birthday:String?
    var timezone:String?
    var about:String?
    var lang:String?
    var menus:AnyObject?
    var cover:String?
    var profile_url:String?
}

extension UserModel{
    init?(json:[String:Any]){
        guard let id = Int((json["id"] as? String)!)
            else{
                return nil
        }
        
        self.id = id
    
        for object in json{
            switch object.key {
            case "name":
                self.name = object.value as? String
            case "email":
                self.email = object.value as? String
            case "avatar":
                self.avatar = object.value  as? AnyObject
            case "last_login":
                self.last_login = object.value as? String
            case "photo_count":
                self.photo_count = Int((object.value as? String)!)
            case "friend_count":
                self.friend_count = Int((object.value as? String)!)
            case "notification_count":
                self.notification_count = Int((object.value as? String)!)
            case "friend_request_count":
                self.friend_request_count = Int((object.value as? String)!)
            case "blog_count":
                self.blog_count = Int((object.value as? String)!)
            case "topic_count":
                self.topic_count = Int((object.value as? String)!)
            case "conversation_user_count":
                self.conversation_user_count = Int((object.value as? String)!)
            case "gender":
                self.gender = object.value as? String
            case "birthday":
                self.birthday = object.value as? String
            case "timezone":
                self.timezone = object.value as? String
            case "about":
                self.about = object.value as? String
            case "lang":
                self.lang = object.value as? String
            case "menus":
                self.menus = object.value as? AnyObject
            case "cover":
                self.cover = object.value as? String
            case "lang":
                self.lang = object.value as? String
            case "profile_url":
                self.profile_url = object.value as? String
            default: break
                
            }
        }
        
    }
}
