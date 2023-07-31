//
//  SuggestSearchModel.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
struct SuggestSearchModel{
    var id:Int?
    var url:String?
    var avatar:String?
    var avatarNSData:Data?
    var owner_id:String?
    var title_1:String?
    var title_2:String?
    var created:String?
    var type:String?
}
extension SuggestSearchModel{
    init?(json:[String:Any]){
        if let id = Int((json["id"] as? String)!){
            self.id = id
        }
        if let url = json["url"] as? String{
            self.url = url
        }
        if let avatar = json["avatar"] as? String{
            self.avatar = avatar
        }
        if let avatarNSData = json["avatarNSData"] as? Data{
            self.avatarNSData = avatarNSData
        }
        if let owner_id = json["owner_id"] as? String{
            self.owner_id = owner_id
        }
        if let title_1 = json["title_1"] as? String{
            self.title_1 = title_1
        }
        if let title_2 = json["title_2"] as? String{
            self.title_2 = title_2
        }
        if let created = json["created"] as? String{
            self.created = created
        }
        if let type = json["type"] as? String{
            self.type = type
        }
    }
}
