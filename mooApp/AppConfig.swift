//
//  AppConfig.swift
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
open class AppConfig{
    let color_main_style = UIColor(red:0.2549,green:0.5216,blue:0.8706,alpha:1.0)
    // Effects on LoginViewController - attributedPlaceholder Form 
    let color_fields_login_style = UIColor.white
    // Effect on loginViewController :
    //   - the fields
    //   - border fields
    //   - cursor in fields
    let color_title = UIColor.white
    // Effect on:
    //   - title on homeTabbarController
    //   - Left search icon on homeTabbarcontroller
    //   - Right cancelButton on SearchViewController
    let color_title_fillter   =  UIColor(red:0.2549,green:0.5216,blue:0.8706,alpha:1.0)
    // Effect on title filter on WhatsNewController
    let color_button_action_background = UIColor(red:0.85098,green:0.85098,blue:0.85098,alpha:1.0)
    let navigationBar_barTintColor = UIColor(red:0.2549,green:0.5216,blue:0.8706,alpha:1.0)
    let navigationBar_textTintColor = UIColor.white
    var webViewWhiteList = [
        "/home/",
        "/activities/ajax_browse/everyone",
        "/activities/ajax_browse/friends"
    ] // It is used for
    var webViewIgnoreBackButtonList = [String]()
    
    let color_login_button_background_style = UIColor(red:138/255,green:179/255,blue:235/255,alpha:1.0)
    // Effect on loginViewController :
}
