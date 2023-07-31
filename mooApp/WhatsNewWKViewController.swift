//
//  WhatsNewViewControllerWK.swift
//  mooApp
//
//  Created by duy on 4/10/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
//
//  FirstViewController.swift
//  TabBar
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit
import WebKit


public protocol WhatsNewWKViewDelegate{
    func openWeb()
}
class WhatsNewWKViewController: AppViewController, WKUIDelegate,WKNavigationDelegate ,WKScriptMessageHandler{
    
    
    var delegateExt : WhatsNewViewDelegate?
   
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var UIWeb: UIView!
    var filterData:[Any]?
    var webView: WKWebView!
    var homeUrl:String?
    var isOpenPhotoPopup = false
    var refreshController:UIRefreshControl? = nil
    
    @IBOutlet weak var webViewBotConstrain: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        initWebViewWK()
    }
    func initWebViewWK(){
        let wkConfig = WKWebViewConfiguration()
        wkConfig.userContentController.add(self,name: "action")
        webViewBotConstrain.constant = (parent as! HomeTabBarViewController).tabBar.frame.size.height
        webView = WKWebView(frame: UIWeb.bounds, configuration: wkConfig)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
        webView.navigationDelegate = self
        addPullToRefreshToWebView()
        UIWeb.addSubview(webView)
        
        let myRequest = URLRequest(url: URL(string:getMooSocialActivitiesURL())!)
        webView.load(myRequest)
    }
    /*! the callback supports for  the javascript in WKWebview to run the action :
     - open Post form
     - open Comment form
     - open Share form
     @param
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        
        if let json = message.body as? [String: Any] {
            
            if let command = json["command"] as? String{
                switch(command) {
                case "openPostFeed"  :
                    if (self.parent?.navigationController?.isNavigationBarHidden)! {
                        UIApplication.shared.statusBarStyle = .lightContent
                        self.parent?.navigationController?.setNavigationBarHidden(false, animated:true)
                    }
                    self.parent?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    self.parent?.performSegue( withIdentifier: "showPostFeedView", sender: self)
                case "openShared"  :
                    print("openShared")
                case "openPhotoUsingWebPopup":
                    isOpenPhotoPopup = true
                    webViewBotConstrain.constant = 0
                    self.parent?.navigationController?.isNavigationBarHidden = true
                    (self.parent as! HomeTabBarViewController).tabBar.isHidden = true
                    UIApplication.shared.isStatusBarHidden = true
                    self.refreshController?.removeFromSuperview()
                case "closePhotoUsingWebPopup":
                    if isOpenPhotoPopup{
                        addPullToRefreshToWebView()
                    }
                    isOpenPhotoPopup = false
                    webViewBotConstrain.constant = (parent as! HomeTabBarViewController).tabBar.frame.size.height
                    self.parent?.navigationController?.isNavigationBarHidden = false
                    (self.parent as! HomeTabBarViewController).tabBar.isHidden = false
                    UIApplication.shared.isStatusBarHidden = false
                case "hideNavigationBar":
                    if !(self.parent?.navigationController?.isNavigationBarHidden)! {
                        UIApplication.shared.statusBarStyle = .default
                        self.parent?.navigationController?.setNavigationBarHidden(true, animated:true)
                    }
                case "showNavigationBar":
                    if (self.parent?.navigationController?.isNavigationBarHidden)! {
                        UIApplication.shared.statusBarStyle = .lightContent
                        self.parent?.navigationController?.setNavigationBarHidden(false, animated:true)
                    }
                case "openComment":
                    if (self.parent?.navigationController?.isNavigationBarHidden)! {
                        UIApplication.shared.statusBarStyle = .lightContent
                        self.parent?.navigationController?.setNavigationBarHidden(false, animated:true)
                    }
                    self.parent?.performSegue( withIdentifier: "showCommentView", sender: json["data"])
                case "openShareFeed":
                    if (self.parent?.navigationController?.isNavigationBarHidden)! {
                        UIApplication.shared.statusBarStyle = .lightContent
                        self.parent?.navigationController?.setNavigationBarHidden(false, animated:true)
                    }
                    self.parent?.performSegue( withIdentifier: "showShareFeedSegue", sender: json["data"])
                default : break
                    
                }
            }
        }
        // var aMessage = {'command':'openPostFeed', data:[5,6,7,8,9]}
        // OR var aMessage = {'command':'openComment', data:[5,6,7,8,9]}
        // OR var aMessage = {'command':'openShared', data:[5,6,7,8,9]}
        //window.webkit.messageHandlers.action.postMessage(aMessage);
    }
    
    /*!  adding the pull refesh in wkwebview
     */
    func addPullToRefreshToWebView(){
        self.refreshController = UIRefreshControl()
        
        self.refreshController?.addTarget(self, action: #selector(refreshWebView), for: UIControlEvents.valueChanged)
        //refreshController.attributedTitle = NSAttributedString(string: "Pull down to refresh...")
        self.refreshController?.tintColor = UIColor.lightGray
        webView.scrollView.addSubview(self.refreshController!)
        
    }
    /*!  the callback for pull refesh action
     */
    func refreshWebView(){
        doRefeshWebview()
        self.refreshController?.endRefreshing()
    }
    func doRefeshWebview(){
        webView.evaluateJavaScript("window.activityAction.fetch(1);") { (result, error) in
            print(result as Any);
            if error != nil {
                print(result as Any)
            }
        }
    }
    /*!  the callback for pull refesh action
     */
    public func setFilterForWebView(_ type:String){
        let js = "window.activityAction.setFilter("+type+");"
        webView.evaluateJavaScript(js);
    }
    /*! the config for openning all links in activies to new WKWebview view
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if var url = navigationAction.request.url {
            
            if( url.absoluteString == getMooSocialActivitiesURL()){
                decisionHandler(.allow)
            }else{
                // open new WKwebview here
                if (self.parent?.navigationController?.isNavigationBarHidden)! {
                    UIApplication.shared.statusBarStyle = .lightContent
                    self.parent?.navigationController?.setNavigationBarHidden(false, animated:true)
                }
                
                let link = SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo(url.absoluteString)
                url = NSURL(string: link)! as URL
                if checkForceLoadWebBrowser(url: url.absoluteString){
                    self.parent?.performSegue( withIdentifier: "showWebBroswer", sender: url)
                }
                else{
                    self.parent?.performSegue( withIdentifier: "showCommentView", sender: url)
                
                }
                decisionHandler(.cancel)
            }
            
        }else{
            decisionHandler(.allow)
        }
        
    }
    
    func checkForceLoadWebBrowser(url: String)-> Bool{
        if url.range(of: "groups/view") != nil{
            return true
        }
        if url.range(of: "events/view") != nil{
            return true
        }
        if isProfileLink(url){
            return true
        }
        if isAlbumLink(url){
            return true
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCommentView" {
            title = ""
            let destinationController = segue.destination as! CommentViewController
            // Is webview
            if isOpenPhotoPopup {
                destinationController.isAutoOpenComment = true
            }
        }
        
    }
    
    /*! Get the url of moosocial activities
     */
    func getMooSocialActivitiesURL()->String{
        if homeUrl == nil{
            homeUrl = AppConfigService.sharedInstance.getBaseURL()+"/activities/ajax_browse/everyone"
            homeUrl = SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo(homeUrl!)
        }
        return homeUrl!
    }
    func isAlbumLink(_ url:String)->Bool{
        return url.range(of:"activities/ajax_load_photo_album") != nil
    }
    
    func isProfileLink(_ url:String)->Bool{
        return url.range(of:"users/view") != nil
    }
    
    override func viewDidLayoutSubviews(){
        
        super.viewDidLayoutSubviews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*webView.scrollView.isScrollEnabled = true
        webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)*/
        doRefeshWebview()
        
        if isOpenPhotoPopup{
            self.parent?.navigationController?.isNavigationBarHidden = true
            UIApplication.shared.isStatusBarHidden = true
        }
    }

}
