//
//  AppHelperService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation

import UIKit
protocol AppHelperDelegate{
    func setNavaigationTitle(_ data:String,haveSubMenu:Bool,dataSubmenu:AnyObject?)
    func showBackButton()
    func hideBackButton()
    func showBackWebButton()
    func hideBackWebButton()
    func isBackButonExits()->Bool
    func isSearchButonExits()->Bool
}
protocol WhatNewDelegate{
    func filtering(_ data:[Any]?)
}
open class AppHelperService : AppService {
    var homeTabbarDelegate:AppHelperDelegate?
    var whatNewDelegate:WhatNewDelegate?
    // Mark: Singleton
    class var sharedInstance : AppHelperService {
        struct Singleton {
            static let instance = AppHelperService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    func setTitle(_ data:String,haveSubMenu:Bool = false,dataSubmenu:AnyObject? = nil){
        if homeTabbarDelegate != nil{
            homeTabbarDelegate!.setNavaigationTitle(data,haveSubMenu:haveSubMenu,dataSubmenu: dataSubmenu)
        }
    }
    func setWhatNewFilter(_ data:[Any]?){
        if whatNewDelegate != nil{
            whatNewDelegate!.filtering(data)
        }
    }
    func showBackButton(){
        if homeTabbarDelegate != nil{
            homeTabbarDelegate!.showBackButton()
        }
    }
    func showBackWebButton(){
        if homeTabbarDelegate != nil{
            homeTabbarDelegate!.showBackWebButton()
        }
    }
    func hideBackButton(){
        if homeTabbarDelegate != nil{
            homeTabbarDelegate!.hideBackButton()
        }
    }
    func hideBackWebButton(){
        if homeTabbarDelegate != nil{
            homeTabbarDelegate!.hideBackWebButton()
        }
    }
    func isBackButonExits()-> Bool{
        if homeTabbarDelegate != nil{
            return homeTabbarDelegate!.isBackButonExits()
        }
        return false
    }
    func isSearchButonExits()-> Bool{
        if homeTabbarDelegate != nil{
            return homeTabbarDelegate!.isSearchButonExits()
        }
        return false
    }
}
