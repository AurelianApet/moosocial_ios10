//
//  SelectListModel.swift
//  mooApp
//
//  Created by tuan on 6/15/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation

class SelectListModel{
    var id: Int = 0
    var avatar: String = ""
    var name: String = ""
    
    func setData(id : Int, avatar : String, name : String){
        self.id = id
        self.avatar = avatar
        self.name = name
    }
}
