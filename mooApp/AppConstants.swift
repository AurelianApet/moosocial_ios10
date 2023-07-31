//
//  AppConstants.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
open class AppConstants{
    // Mark : Token
    static let MOO_TOKEN = "Moo.App.Token"
    static let MOO_TIME_AT_ENTER_BACKGROUND  = "Moo.App.Time.EnterBackground"
    static let MOO_SETTING = "Moo.App.Setting"
    static let MOO_SOCIAL_PROVIDER_FACEBOOK = "facebook"
    static let MOO_SOCIAL_PROVIDER_GOOGLE = "google"
    static let MOO_SOCIAL_IMAGE_CELL_WIDTH = 30
    // Mark : Message
    static let MESSAGE_CHECKING_INTENERT = NSLocalizedString("all_page_message_checking_internet",comment:"all_page_message_checking_internet")
    static let MESSAGE_AUTHENTICATING_USER = NSLocalizedString("all_page_message_authenticating_user",comment:"all_page_message_authenticating_user")
    static let MESSAGE_NO_RESULT_FOUND = NSLocalizedString("all_page_message_no_result_found",comment:"all_page_message_no_result_found")
    static let MESSAGE_RERESING_TOKEN = NSLocalizedString("all_page_message_rerfesing_token",comment:"all_page_message_rerfesing_token")
    
    // Mark : Config
    static let CONFIG_PATH_FILE_APP = Bundle.main.path(forResource: "appConfig",ofType:"json")
    static let CONFIG_PATH_FILE_EMOJI = Bundle.main.path(forResource: "emoji",ofType:"json")
    //static let SEARCH_IMAGE_CELL_WIDTH = 100
    // Mark : segue
    static let SEGUE_GOTO_MORE_WEB_VIEW_CONTROLLER = "goto_more_webview"
    static let SEGUE_GOTO_MORE_WEB_VIEW_CONTROLLER_FROM_SUGGEST_SEARCH = "goto_more_webview_from_suggest_search"
    // Mark : Actions
    static let ACTION_DEFAULT_ON_HOME_TAB_BAR_CONTROLLER = 0
    static let ACTION_ACTIVE_WEB_ON_WHATS_NEW_FROM_OUTSIDE = 1
    static let ACTION_ACTIVE_WEB_ON_WHATS_NEW_FROM_NOTIFICATIONS = 2
    static let ACTION_SEND_LINK_TO_WEBVIEW_FROM_WHATS_NEW_CONTROLLER = 0
    static let ACTION_SEND_LINK_TO_WEBVIEW_FROM_SEARCH_CONTROLLER = 1
    static let ACTION_SEND_LINK_TO_WEBVIEW_FROM_MORE_CONTROLLER = 2
    // Mark : label 
    static let ALERT_DIALOG_TITLE  = NSLocalizedString("all_page_alert_dialog_title",comment:"all_page_alert_dialog_title")
    static let ALERT_DIALOG_TITLE_MESSAGE  = NSLocalizedString("all_page_alert_dialog_message",comment:"all_page_alert_dialog_message")
    static let ALERT_DIALOG_BUTTON = NSLocalizedString("all_page_alert_dialog_button",comment:"all_page_alert_dialog_button")
    
    // Mark : share feed type
    static let SHARE_FEED_TYPE_NORMAL = "#me"
    static let SHARE_FEED_TYPE_FRIEND = "#friend"
    static let SHARE_FEED_TYPE_GROUP = "#group"
    static let SHARE_FEED_TYPE_EMAIL = "#email"
}
