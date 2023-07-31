//
//  GCMService.swift
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
import Firebase

open class GCMsService : AppService {
    // Mark: Properties
    var registrationToken:String?
    var registrationOptions = [String: AnyObject]()
    var isRegisteredCallbackForGCM = false
    // Mark: init
    override init() {
        super.init()
    }
    // Mark: Singleton
    class var sharedInstance : GCMsService {
        struct Singleton {
            static let instance = GCMsService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    // Mark: process
    func saveTokenToServer(_ callback:Bool=false)->(){
        if callback {
                    
            if let token = InstanceID.instanceID().token() {
                registrationToken = token
            }
            
            if registrationToken != nil{
                AlamofireService.sharedInstance.privateSession!.request(api!["URL_GCM","hasToken"],method:.post,parameters: ["token":registrationToken!],encoding: JSONEncoding.default )
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .success( _):
                            // JSON is NSARRAY
                            self.registerCallbackForGCM()
                            
                            
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
                
            }else{
              
            }
        }
        
        
    }
    func deleteTokenOnServer(_ callback:Bool=false)->(){
        if let token = InstanceID.instanceID().token() {
            registrationToken = token
        }
    
        if registrationToken != nil{
            AlamofireService.sharedInstance.privateSession!.request( api!["URL_GCM_DELETE","hasToken"],method:.post,parameters: ["token":registrationToken!],encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success( _):

                        if callback {
                            self.saveTokenToServer(true)
                        }
                        
                        break
                    case .failure(let error):
                        print("\(error)")
                        if let data = response.data {
                            
                            print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                            
                        }
                        
                    }
                    
            }
        }
        
    }
    func registerCallbackForGCM(){
    }
    func updateRegistrationStatus(_ notification: Notification) {
        
    }
    
    func showReceivedMessage(_ notification: Notification) {
    }
    
}
