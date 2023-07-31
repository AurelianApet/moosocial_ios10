//
//  SharedPreferencesService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
open class SharedPreferencesService : NSObject {
    // Mark: Properties
    var token:TokenModel?
    var systemLanggaue:String
    // Mark: init
    override init() {
        // Detect current langaue code
        let code = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)! as! String
        systemLanggaue = ISO6392Service.sharedInstance.convert(code)
        // End detect 
        
        
        super.init()
        

    }
    // Mark: Singleton
    class var sharedInstance : SharedPreferencesService {
        struct Singleton {
            static let instance = SharedPreferencesService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    // Mark: process
    func saveToken(_ token:TokenModel?){
        if token != nil{
            self.token = token
            if let json = token?.toJSON() {
                let defaults = UserDefaults.standard
                defaults.set(json, forKey: AppConstants.MOO_TOKEN)
            }

        }
    }
    func loadToken(){
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: AppConstants.MOO_TOKEN){
            if let data = token.data(using: String.Encoding.utf8) {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                self.token = TokenModel(json: json as! [String : Any])
            }
        }
    }
    func clearToken(){
        let appDomain = Bundle.main.bundleIdentifier!
        
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    func getCurrentSystemLanggaue()-> String{
        return systemLanggaue
    }
    func bindTokenAndLanggaueTo(_ link:String)->String{
        var tmp = link;
        let url = URL(string:link)
        var query = url?.query
        if query != nil{
            if query?.lowercased().range(of:"access_token=") == nil {
                query = query! + "&access_token=" + (token?.access_token)!
            }
            if query?.lowercased().range(of:"language=") == nil{
                query = query! + "&language=" + getCurrentSystemLanggaue()
            }
            tmp = tmp.replacingOccurrences(of: (url?.query)!, with: query!, options: .literal, range: nil)
        }else{
            tmp = tmp + "?access_token=" + (token?.access_token)!
            tmp = tmp + "&language=" + getCurrentSystemLanggaue()
        }
        
        return tmp
    }
    
    func saveSettings(settings: AnyObject?){
        if settings != nil{
            let defaults = UserDefaults.standard
            defaults.set(settings, forKey: AppConstants.MOO_SETTING)
        }
    }
    
    func loadSettings(key: String) -> AnyObject!{
        let defaults = UserDefaults.standard
        let settings : [String : AnyObject]! = defaults.object(forKey: AppConstants.MOO_SETTING) as! [String : AnyObject]!
        if (settings != nil && settings[key] != nil){
            return settings[key]!
        }
        return nil
    }
}
