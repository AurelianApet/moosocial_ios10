//
//  ValidateService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
import SystemConfiguration
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


open class ValidateService : NSObject {
    // Mark: Properties
    let MESSAGE_INVALID_EMAIL = NSLocalizedString("all_page_message_invalid_email",comment:"all_page_message_invalid_email")
    let MESSAGE_INVALID_PASSWD = NSLocalizedString("all_page_message_invalid_paswd",comment:"all_page_message_invalid_paswd")
    let MESSAGE_INVALID_TOKEN = NSLocalizedString("all_page_message_invalid_token",comment:"all_page_message_invalid_token")
    let MESSAGE_INVALID_USER = NSLocalizedString("all_page_message_invalid_user",comment:"all_page_message_invalid_user")
    let MESSAGE_EXPIRED_TOKEN = NSLocalizedString("all_page_message_expired_token",comment:"all_page_message_expired_token")
    let MESSAGE_NOT_IMAGE  = NSLocalizedString("all_page_message_not_image",comment:"all_page_message_not_image")
    let MESSAGE_NOT_INTERNET = NSLocalizedString("all_page_message_not_internet",comment:"all_page_message_not_internet")
    let MESSAGE_KEYWORD_MORE_CHARACTERS = NSLocalizedString("all_page_message_keyword_more_characters",comment:"all_page_message_keyword_more_characters")
    var lastMessage:String?
    var limitKeywordForSearching = 1
    // Mark: init
    override init() {
        super.init()
    }
    // Mark: Singleton
    class var sharedInstance : ValidateService {
        struct Singleton {
            static let instance = ValidateService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    // Mark: process
    func getLastMessage()->String{
        return lastMessage!
    }
    func isEmail(_ testStr:String)->Bool{
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailTest.evaluate(with: testStr){
            lastMessage = MESSAGE_INVALID_EMAIL
            return false
        }
        
        return true
    }
    func isPasswd(_ testStr:String) -> Bool {
        
        if testStr.characters.count > 0 {
            return true
        }
        lastMessage = MESSAGE_INVALID_PASSWD
        return false
    }
    func isToken(_ token:TokenModel)->Bool{
        if token.access_token == nil{
            lastMessage = MESSAGE_INVALID_TOKEN
            return false
        }
        return true
    }
    func isExpiredToken(_ token:TokenModel)->Bool{ 
        if !isToken(token){
            lastMessage = MESSAGE_EXPIRED_TOKEN
            return true
        }
        if token.refresh_token == nil{
            lastMessage = MESSAGE_INVALID_TOKEN
            return true
        }
        if token.time_expired < Date().timeIntervalSince1970 { // true is <
            return true
        }
        return false
    }
    func hasToken()->Bool{
        SharedPreferencesService.sharedInstance.loadToken()
   
        if SharedPreferencesService.sharedInstance.token != nil {
            return isToken(SharedPreferencesService.sharedInstance.token!)
        }
        return false
    }
    func isStringEmpty(_ string:String)->Bool{
        if string.characters.count == 0{
            return false
        }
        return true
    }
    func isUser()->Bool{
        lastMessage = MESSAGE_INVALID_USER
        return false
    }
    func hasInternet()->Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        
        if !(isReachable && !needsConnection){
            lastMessage = MESSAGE_NOT_INTERNET
            return false
        }
        return true

    }
    func isImage()->Bool{
        lastMessage = MESSAGE_NOT_IMAGE
        return false
    }
    func isAllowKeyword(_ keyword:String)->Bool{
        if keyword.characters.count >= limitKeywordForSearching{
            return true
        }else{
            lastMessage = MESSAGE_KEYWORD_MORE_CHARACTERS
            return false
        }
    }
}
