//
//  FriendModel.swift
//  mooApp
//
//  Created by duy on 5/5/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation

struct FriendModel{
    let id:Int
    var url:String?
    var name:String?
    var photoCount:Int?
    var friendCount:Int?
    var image:[String:String]?
}

extension FriendModel{
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
            case "url":
                self.url = object.value as? String
            case "photoCount":
                self.photoCount = Int((object.value as? String)!)
            case "friendCount":
                self.friendCount = Int((object.value as? String)!)
            case "image":
                self.image = object.value as? [String:String]
            default: break
                
            }
        }
        
    }
}
