//
//  UserService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit
import Alamofire
open class UserService : AppService {
    // Mark: Properties
    
    var meModel:UserModel?
    // Mark: init
    override init() {
        super.init()
    }
    // Mark: Singleton
    class var sharedInstance : UserService {
        struct Singleton {
            static let instance = UserService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    // Mark: process
    func get(_ refesh:Bool = false)->UserModel?{
        if refesh{
            me()
            return nil
        }else{
            if meModel == nil{
                me()
                return nil
            }
        }
        return meModel
    }
    func me(){
        

        AlamofireService.sharedInstance.privateSession!.request(api!["URL_USER_ME","hasToken"],method:.get,encoding:JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON ):
                    // JSON is NSARRAY
                
                    
                    //self.meModel.load(nil,dictionary:JSON as? NSDictionary)
                    let json = JSON as! [String:Any]
                        self.meModel = UserModel(json:json)
                    
                        self.dispatch("UserService.me.Success",data:self)
              
                    break
                    

                    
                    
                    
                case .failure(let error):
                    
                    if let data = response.data {
                        
                        if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                            AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                            print("\(error)")
                        }
                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                        
                    }
                    
                }
        }

    }
    func saveAvatar(_ image:UIImage?){
        AlamofireService.sharedInstance.privateSession!.upload(multipartFormData: {
            multipartFormData in
            
            if let _image = image {
                if let imageData = UIImageJPEGRepresentation(_image, 0.5) {
                    multipartFormData.append(imageData, withName: "qqfile", fileName: "file.png", mimeType: "image/png")
                }
            }
            /*
             for (key, value) in parameters {
             multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
             }
             */
            },to: api!["URL_USER_ME_AVATAR","hasToken"],encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let data = response.result.value as? NSDictionary {
                           
                            if let error = data["error"] as? String{
                                AlertService.sharedInstance.process(error )
                            }else{
                                self.dispatch("UserService.saveAvatar.Success",data: data as AnyObject?)
                            }
                            
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    func create(_ email:String,name:String,passwd:String,birthday:String?,gender:String?){
        AlamofireService.sharedInstance.privateSession!.request( api!["URL_SIGNUP"],method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON ):
                    // JSON is NSARRAY
                    let data = JSON as? NSDictionary
                    if let key = data?["key"]{
                    //if let key = JSON["key"]{
             
                        let api = AppConfigService.sharedInstance.apiSetting
                        let securityToken = (AppConfigService.sharedInstance.getApiKey() as String) + (key as! String)
                        var parameters:Parameters = [
                            "key": (key as! String),
                            "security_token":securityToken.md5,
                            "email":email,
                            "name":name,
                            "password":passwd,
                            "password2":passwd
                        ]
                        
                        if birthday != "" {
                            parameters["birthday"] = birthday
                        }
                        if gender != "" {
                            parameters["gender"] = gender
                        }
                        AlamofireService.sharedInstance.privateSession!.request(api!["URL_SIGNUP"],method:.post,parameters:parameters)
                            .validate()
                            .responseJSON { response in
                               
                                switch response.result {
                                case .success( let JSON):
                                    let data = JSON as? NSDictionary
                                    parameters["approve_users"] = data?["approve_users"]
                                    
                                    self.dispatch("UserService.create.Success",data: parameters as AnyObject?)
                                    break
                                   
                                    
                                    
                                    
                                    
                                case .failure(let error):
                                     self.dispatch("UserService.create.Failure",data: nil)
                                    if let data = response.data {
                                        
                                        if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                                            AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                                            print("\(error)")
                                        }
                                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                                        
                                    }
                                    
                                }
                        }

                    }
                    
                    break;
                    
                    
                    
                    
                case .failure(let error):
                    print("\(error)")
                    if let data = response.data {
                        
                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                        
                    }
                    
                }
        }

    }
    
    func forgotPassword( _ email : String )
    {
        AlamofireService.sharedInstance.privateSession!.request( api!["URL_FORGOT_PASSWORD"],method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON ):
                    // JSON is NSARRAY
                    let data = JSON as? NSDictionary
                    if let key = data?["key"]{
                        //if let key = JSON["key"]{
                        
                        let api = AppConfigService.sharedInstance.apiSetting
                        let securityToken = (AppConfigService.sharedInstance.getApiKey() as String) + (key as! String)
                        let parameters:Parameters = [
                            "key": (key as! String),
                            "security_token":securityToken.md5,
                            "email": email
                        ]
                        
                        AlamofireService.sharedInstance.privateSession!.request(api!["URL_FORGOT_PASSWORD"],method:.post,parameters:parameters)
                            .validate()
                            .responseJSON { response in
                                
                                switch response.result {
                                case .success( _):
                                    self.dispatch("UserService.forgot.Success")
                                    break
                                    
                                case .failure(let error):
                                    self.dispatch("UserService.forgot.Failure",data: nil)
                                    if let data = response.data {
                                        
                                        if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                                            AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                                            print("\(error)")
                                        }
                                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                                        
                                    }
                                    
                                }
                        }
                        
                    }
                    
                    break;
                    
                case .failure(let error):
                    print("\(error)")
                    if let data = response.data {
                        
                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                        
                    }
                    
                }
        }
    }
    
}

extension String  {
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }
}
