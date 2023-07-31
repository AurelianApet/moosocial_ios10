//
//  GroupModel.swift
//  mooApp
//
//  Created by tuan on 6/21/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation

struct GroupModel{
    let id:Int
    var name:String?
    var group_user_count:Int?
    var photo:[String:String]?
    var image:String?
}

extension GroupModel{
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
            case "group_user_count":
                self.group_user_count = Int((object.value as? String)!)
            case "photo":
                self.photo = object.value as? [String:String]
                self.image = object.value as? String
            default: break
                
            }
        }
        
    }
}
