//
//  AppService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
import Alamofire

protocol AppServiceDelegate {
    func serviceCallack(_ identifier:String,data:AnyObject?)
}

open class AppService : NSObject {
    //var serviceDelegate : AppServiceDelegate?
    var serviceDelegate = [String:AppServiceDelegate]()
    let api = AppConfigService.sharedInstance.apiSetting
    func dispatch(_ identifier:String,data:AnyObject? = nil){
        if(!serviceDelegate.isEmpty){
            for (_,service) in serviceDelegate {
                service.serviceCallack(identifier, data: data)
            }
        }
        
    }
    func registerCallback(_ delegate:AppServiceDelegate)-> Self {
        //self.serviceDelegate = delegate
        let name = String(describing: type(of: delegate))
        //if !serviceDelegate.contains(where: { $0.key == name}){
            serviceDelegate[name] = delegate
        //}
        return self
    }
    func unRegisterCallack(_ delegate:AppServiceDelegate){
        let name = String(describing: type(of: delegate))
        if let index = serviceDelegate.index(where: { $0.key == name }) {
            serviceDelegate.remove(at: index)
        }
    }
}
