//
//  TokenModel.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



struct TokenModel: JSONSerializable{
    var access_token:String?
    var expires_in:String?
    var refresh_token:String?
    var scope:String?
    var token_type:String?
    var time_expired:Double?
    func isExpired()-> Bool{
        if time_expired == nil{
            return true
        }
        if time_expired < Date().timeIntervalSince1970{
            return true
        }
        return false
    }
}

extension TokenModel{
    init?(json:[String:Any]){
       
        guard let access_token = json["access_token"] as? String,
            let refresh_token = json["refresh_token"] as? String,
            let token_type = json["token_type"] as? String
        else{
            return nil
        }
        self.access_token = access_token
        
        self.refresh_token = refresh_token
        if  let scope = json["scope"] as? String{
            self.scope = scope
        }
        
        self.token_type = token_type
        
        if let has_time_expired = json["time_expired"] as? String{
            self.time_expired = Double(has_time_expired)
        }

        if let expires_in = json["expires_in"] as? Int{
            self.expires_in = String(expires_in)
        }
        
        if let expires_in = json["expires_in"] as? String{
            self.expires_in = expires_in
        }
        
        if self.expires_in != nil{
            if let timeExpiredIn = Double(self.expires_in!) {
                self.time_expired = Date().addingTimeInterval(timeExpiredIn).timeIntervalSince1970
            }
        }
    }
}
