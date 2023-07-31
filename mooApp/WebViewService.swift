//
//  WebViewService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//  Copyright © 2015 moosocialloft. All rights reserved.
//

import Foundation
import UIKit
struct WebParamater{
    var title:String?
    var url:String?
}
open class WebViewService : NSObject,UIWebViewDelegate,UIScrollViewDelegate {
    // Mark: Properties
    var webview:UIWebView?
    var webParam:WebParamater=WebParamater()
    var topViewController:AppViewController?
    var historyURL = [URLRequest]()
    var ingnoreAddHistory = false
    var currentURL:URL?
    var pushNotificationURL:String?
    var isAppCallFromNotificationURLAndTimeToReset=false
    let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var flag_loading_link_from_object = AppConstants.ACTION_SEND_LINK_TO_WEBVIEW_FROM_WHATS_NEW_CONTROLLER
    var URLReload:String?
    var mustHaveUpdateNotifications:Bool = false
    var lastOffsetY:CGFloat?
    override init() {
        super.init()
        
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.color = AppConfigService.sharedInstance.config.color_main_style
        loadingIndicator.hidesWhenStopped = true
    }
    // Mark: Singleton
    class var sharedInstance : WebViewService {
        struct Singleton {
            static let instance = WebViewService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    // Mark: Webview behavior
    open func webViewDidStartLoad(_ webView: UIWebView) {

        startShowLoadingAnimate()
       
    }
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //print("shouldStartLoadWithRequest")
        detectLinkForUpdatingNotifications((request.url?.absoluteString)!)
        //NSLog("Loading: %@", request.URL!);
        return true
    }
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        //print("webViewDidFinishLoad")
        //NSLog("didFinish: %@; stillLoading: %@ history: %@", webView.request!.URL!,(webView.loading ? "YES": "NO"),String(historyURL.count));
        
        updateWebParams()
        setTitle()
        detectLinkForBackButton()
       
        if !detectLinkForFilter("\(currentURL)") {
         (topViewController as! WhatsNewViewController).hideFillter()
        }
        
        updateNotifications()
        // notifications/ajax_view
        stopShowLoadingAnimate()
        if !ingnoreAddHistory && webView.request?.url?.absoluteString != "about:blank" {
            historyURL.append(webView.request!);
        }else{
            //ingnoreAddHistory = false
        }
        
    }
    open func goback(){
        webview?.goBack()
        if historyURL.count > 0{
            historyURL.removeLast()
        }
        
    }
    open func isAllowBack()->Bool{
        if historyURL.count > 2{
            return true
        }
        return false
    }
    open func updateWebParams(){
        webParam.title = webview!.stringByEvaluatingJavaScript(from: "document.title")
        webParam.url   = webview!.stringByEvaluatingJavaScript(from: "location.protocol + '//' + location.host + location.pathname")
    }
    open func setTitle(){
        //if !AppConfigService.sharedInstance.config.webViewWhiteList.contains(webParam.url!){
        if AppConfigService.sharedInstance.isAllowSetTitle(webParam.url!){
            AppHelperService.sharedInstance.setTitle(webParam.title!)
            AppHelperService.sharedInstance.setWhatNewFilter(nil)
        }else{
            if let linkData = AppConfigService.sharedInstance.nsLinksData[webParam.url!]{
                let titleLocalized = NSLocalizedString(linkData["title"] as! String,comment:linkData["title"] as! String)
                AppHelperService.sharedInstance.setTitle(titleLocalized)
                AppHelperService.sharedInstance.setWhatNewFilter(linkData["filter"] as! [Any]?)

            }
            

            
        }
    }
    open func detectLinkForBackButton(){

        if AppConfigService.sharedInstance.isAllowSetBackButton(webParam.url!){
            if !AppHelperService.sharedInstance.isSearchButonExits(){

                if !AppHelperService.sharedInstance.isBackButonExits(){
                   AppHelperService.sharedInstance.showBackWebButton()
                }else{
                    AppHelperService.sharedInstance.hideBackWebButton()
                }
                
            }

         
        }else{
            AppHelperService.sharedInstance.hideBackButton()
            AppHelperService.sharedInstance.hideBackWebButton()        }
    }
    open func detectLinkForFilter(_ url:String)->Bool{
        
        if((url.range(of: "/users/")) != nil || (url.range(of: "/friends/")) != nil || (url.range(of: "conversations/ajax_browse")) != nil){
            return false
        }
        
        if (topViewController?.isKind(of: WhatsNewViewController.self)) != nil && url.range(of: "/pages/") == nil && url.range(of: "/home/contact") == nil{
            return true
        }
        return false;
    }
    open func detectLinkForUpdatingNotifications(_ url:String){
        if url.range(of: "/notifications/ajax_view/") != nil || url.range(of: "/conversations/view/") != nil{
            mustHaveUpdateNotifications = true
        }
    }
    open func updateNotifications(){
        
        if  mustHaveUpdateNotifications{
            NotificationService.sharedInstance.me()
            mustHaveUpdateNotifications = false
        }
        
        
    }
    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //NSLog("didFail: %@; stillLoading: %@", webView.request!.URL!,(webView.loading ? "YES": "NO"));
        stopShowLoadingAnimate()
    }
    // Mark: process
    func set(_ webview:UIWebView?,topVController:AppViewController?){
        
        if(webview != nil){
            
            self.webview = webview
            webview?.loadHTMLString("", baseURL:nil)
            webview?.stopLoading()
            webview?.delegate = self
            self.webview?.scrollView.delegate = self;
            webview?.addSubview(loadingIndicator)
        }
        if(topVController != nil){
            self.topViewController = topVController
        }
        
    }
    func modifiedUserAgent(_ appendString:String?){
        let userAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")! + appendString!
        UserDefaults.standard.register(defaults: ["UserAgent" : userAgent])
    }
    func makeFullFrame()->Bool{
        return false
    }
    
    func goURL( _ url:String,hasAccessToken:Bool=true){
        var url = url
        if hasAccessToken {
            url = addToken(url)
        }
        print("goURL:\(url)")
        url = addLanguage(url)
        let goURL = URL(string:url)
        currentURL = goURL

        let requestObj = URLRequest(url: goURL!);
        if webview != nil{
            webview!.loadRequest(requestObj);
        }
        
    }
    func addToken(_ url:String) ->String{
        return url + "?access_token=" + (SharedPreferencesService.sharedInstance.token?.access_token)!
    }
    func addLanguage(_ url:String)->String{
        if url.range(of: "?") == nil{
            return url + "?language=" + SharedPreferencesService.sharedInstance.getCurrentSystemLanggaue()
        }
        return url + "&language=" + SharedPreferencesService.sharedInstance.getCurrentSystemLanggaue()
        
    }
    func goHome(_ hasAccessToken:Bool=true){
       
        
        goURL(AppConfigService.sharedInstance.getBaseURL()+"/activities/ajax_browse/everyone",hasAccessToken: hasAccessToken)
    }
    // Mark : UIScrollViewDelegate Methods
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastOffsetY = scrollView.contentOffset.y;
    }
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let hide:Bool = (scrollView.contentOffset.y > (self.lastOffsetY!+16))
        //topViewController?.navigationController?.setNavigationBarHidden(hide, animated: true)
        if detectLinkForFilter("\(currentURL)") {
            if hide {
                (topViewController as! WhatsNewViewController).hideFillter()
            }else{
                (topViewController as! WhatsNewViewController).showFilter()
            }
        }
    }
    open func startShowLoadingAnimate(){
        if ((topViewController?.isKind(of: WhatsNewViewController.self)) != nil) {
            (topViewController as! WhatsNewViewController).webviewIndicator.startAnimating()
        }else{
            loadingIndicator.startAnimating()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    open func stopShowLoadingAnimate(){
        if ((topViewController?.isKind(of: WhatsNewViewController.self)) != nil) {
            (topViewController as! WhatsNewViewController).webviewIndicator.stopAnimating()
        }else{
            loadingIndicator.stopAnimating()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
