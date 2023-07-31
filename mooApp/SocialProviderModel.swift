//
//  SocialProviderModel.swift
//  mooApp
//
//  Created by tuan on 5/31/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation

class SocialProviderModel{
    var provider: String = ""
    var provider_uid: String = ""
    var socialEmail: String = ""
    var displayName: String = ""
    var photoUrl: String = ""
    var accessToken: String = ""
    
    func setData(provider : String, id : String, socialEmail : String, displayName : String, photoUrl : String, accessToken : String){
        self.provider = provider
        self.provider_uid = id
        self.socialEmail = socialEmail
        self.displayName = displayName
        self.photoUrl = photoUrl
        self.accessToken = accessToken
    }
}
