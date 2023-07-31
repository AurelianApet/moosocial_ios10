//
//  WKWebView.swift
//  mooApp
//
//  Created by duy on 4/12/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import WebKit
struct WebAction{
    var type = "redirect"
    var javascript = ""
    var url = ""
}
class WebViewBrowserController: UIViewController, WKUIDelegate,UIPopoverPresentationControllerDelegate,OptionPoperverControllerDelegate,WKNavigationDelegate, WKWeViewDelegate, WKScriptMessageHandler, CommentDataDelegate {
    
    @IBOutlet weak var navTitleButton: UIButton!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var findButton: UIBarButtonItem!
    
    @IBOutlet weak var videUploadButton: UIBarButtonItem!
    var webView: WKWebView!
    var url:URL?
    var filter:[String] = []
    var filterURL:[String] = []
    var optFilterIsActived = 0
    var isFirstLoad  = true
    var webAction = WebAction()
    var isOpenLinkInNewView = true
    var isAddNew = false
    var isAutoOpenComment = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initStyle()
        initFilter()
        initAction()
        setFilter()
        addPullToRefreshToWebView()
        if url != nil{
            let myRequest = URLRequest(url: url!)
            webView.load(myRequest)
        }
    }
    
    func addPullToRefreshToWebView(){
        let refreshController:UIRefreshControl = UIRefreshControl()
        
        refreshController.addTarget(self, action: #selector(WhatsNewViewController.refreshWebView(_:)), for: UIControlEvents.valueChanged)
        //refreshController.attributedTitle = NSAttributedString(string: "Pull down to refresh...")
        refreshController.tintColor = UIColor.lightGray
        webView.scrollView.addSubview(refreshController)
        
    }
    
    func refreshWebView(_ refresh:UIRefreshControl){
        doReload()
        refresh.endRefreshing()
    }
    
    func doReload(){
        isFirstLoad = true
        //initStyle()
        webView.reload()
    }
    
    func initStyle(){
        self.navigationController?.navigationBar.tintColor = AppConfigService.sharedInstance.config.color_title
        navTitleButton.setTitleColor(AppConfigService.sharedInstance.config.color_title, for: UIControlState())
        navTitleButton.isHidden = true
        navigationItem.rightBarButtonItems = nil
        addButton.tintColor = AppConfigService.sharedInstance.config.color_title
        findButton.tintColor = AppConfigService.sharedInstance.config.color_title
    }
    func initFilter(){
        if url != nil {
            let newUrl = getURLWithoutQuery(url!)
            if let linkData = AppConfigService.sharedInstance.nsLinksData[newUrl]{
                let filterData = linkData["filter"] as! [Any]?
                if filterData != nil && (filterData?.count)! > 0 {
                    
                    for case let item as [String:String] in filterData! as [Any]{
                        filter.append(NSLocalizedString(item["label"]!,comment:item["label"]!))
                        filterURL.append(item["url"]!)
                    }
                }
            }
        }
    }
    func initAction(){
        if url != nil {
            let newUrl = getURLWithoutQuery(url!)
            if let linkData = AppConfigService.sharedInstance.nsLinksData[newUrl]{
                
                
                if let actionData = linkData["action"] as? [String:String]{
                    if let type = actionData["type"]{
                        switch type {
                        case "add":
                            navigationItem.rightBarButtonItem = addButton
                        case "find":
                            navigationItem.rightBarButtonItem = findButton
                        default:
                            break
                        }
                    }
                    if let url = actionData["url"]{
                        webAction.url = AppConfigService.sharedInstance.getBaseURL() + url
                    }
                    if let jsCallback = actionData["js_callback"]{
                        webAction.javascript = jsCallback
                        webAction.type = "callback"
                    }
                }
                if newUrl == (AppConfigService.sharedInstance.getBaseURL() + "/videos/browse/all"){
                    
                    let settings : [String : AnyObject]! = UserDefaults.standard.object(forKey: AppConstants.MOO_SETTING) as! [String : AnyObject]!
                    if let plugins = settings["plugin"] as? [String:AnyObject] {
                        
                        if let video = plugins["UploadVideo"] as? Bool {
                            if video {
                                navigationItem.rightBarButtonItems = [videUploadButton,navigationItem.rightBarButtonItem!]

                            }
                        }
                    }
                }
            }
        }
    }
    func setFilter(){
        if filter.count > 0 {
            navTitleButton.isHidden = false
            let naviTitle = filter[optFilterIsActived] + " ▾"
            navTitleButton.setTitle(naviTitle, for: UIControlState())
            navTitleButton.setImage(nil, for: UIControlState())
        }
        
    }
    func menuPoperverSelected(_ key:Int){
        optFilterIsActived = key
        setFilter()
        isFirstLoad = true
        let wUrl = AppConfigService.sharedInstance.getBaseURL() + filterURL[key]
        let myRequest = URLRequest(url: URL(string:SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo(wUrl))!)
        webView.load(myRequest)
    }
    func getURLWithoutQuery(_ url:URL)->String{
        let aString = url.absoluteString
        if let query = url.query {
            let newString = aString.replacingOccurrences(of: "?"+query, with: "", options: .literal, range: nil)
            return newString
        }
        return aString
    }
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController.add(self,name: "action")
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    @IBAction func onTapNavTitleButton(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popoverId") as! OptionPoperverController
        
        vc.modalPresentationStyle = .popover
        
        vc.menu = filter
        vc.optActived = optFilterIsActived
        vc.delegateEx = self
        var height = 100;
        switch(vc.menu.count){
        case 1 :
            height = 50;
        case 2:
            height = 89;
        case 3 :
            height = 150;
        case 4 :
            height = 190;
        case 5 :
            height = 220;
        default:
            break;
        }
        vc.preferredContentSize =  CGSize(width:180,height:height)
        vc.tableView.reloadData();
        
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.permittedArrowDirections = .any
        popover.sourceView = sender as? UIView
        popover.sourceRect = (sender as AnyObject).bounds
        
        
        // present the popover
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onAddButton(_ sender: Any) {
        onWebAction()
    }
    
    @IBAction func onFindButton(_ sender: Any) {
        onWebAction()
    }
    
    @IBAction func onVideoUploadButton(_ sender: Any) {
        let url = URL(string: AppConfigService.sharedInstance.getBaseURL() + "/upload_videos/ajax_upload")
        isOpenLinkInNewView = false
        self.performSegue(withIdentifier: "showWKWebViewFromBrowser", sender: url)    }
   
    func onWebAction(){
        switch webAction.type {
        case "redirect":
            let url = URL(string: webAction.url)
            isOpenLinkInNewView = false
            self.performSegue(withIdentifier: "showCommentViewBrowser", sender: url)
            
        case "callback":
            webView.evaluateJavaScript(webAction.javascript) { (result, error) in
                print(result as Any);
                if error != nil {
                    print(result as Any)
                }
            }
        default:
            break;
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !isFirstLoad && webView.url != nil{
            let link = URL(string:SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo((webView.url?.absoluteString)!))!
            isFirstLoad = true
            let myRequest = URLRequest(url: link)
            webView.load(myRequest)
        }
        if isNotificationLink((webView.url?.absoluteString)!){
            isFirstLoad = false
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if !isFirstLoad && navigationAction.request.url != nil{
            let link = URL(string:SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo((navigationAction.request.url!.absoluteString)))!
            if checkAllowRedirectCommentView(link.absoluteString){
                self.isFirstLoad = false
                self.performSegue( withIdentifier: "showCommentViewBrowser", sender: link)
                decisionHandler(.cancel)
            }
            else if isNotificationLink((self.url?.absoluteString)!) && !isFirstLoad{
                self.url = link
                isFirstLoad = true
                let myRequest = URLRequest(url: link)
                webView.load(myRequest)
                decisionHandler(.allow)
            }
            else if isSubmitAttendEventLink(link.absoluteString) || isSubmitUploadPhotoLink(link.absoluteString){
                isFirstLoad = true
                decisionHandler(.allow)
            }
            else{
                decisionHandler(.allow)
            }
        }
        else{
            decisionHandler(.allow)
        }
    }
    
    func isNotificationLink(_ url: String)-> Bool{
        if url.range(of: "notifications/ajax_view") != nil{
            return true
        }
        return false
    }
    
    func isSubmitAttendEventLink(_ url: String)-> Bool{
        if url.range(of: "events/do_rsvp") != nil{
            return true
        }
        return false
    }
    
    func isSubmitUploadPhotoLink(_ url: String)-> Bool{
        if url.range(of: "photos/do_activity") != nil{
            return true
        }
        return false
    }
    
    //group, event, other plugins reload page
    func checkAllowRedirectCommentView(_ url: String)-> Bool{
        if url.range(of: "blogs/view") != nil{
            return true
        }
        if url.range(of: "photos/view") != nil{
            return true
        }
        if url.range(of: "albums/view") != nil{
            return true
        }
        if url.range(of: "videos/view") != nil{
            return true
        }
        if url.range(of: "topics/view") != nil{
            return true
        }
        if url.range(of: "users/profile") != nil{
            return true
        }
        if url.range(of: "conversations/ajax_send") != nil{
            return true
        }
        if url.range(of: "reports/ajax_create") != nil{
            return true
        }
        return false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if isFirstLoad {
            isFirstLoad = false
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCommentViewBrowser" {
            title = ""
            let destinationController = segue.destination as! CommentViewController
            destinationController.delegate = self
            destinationController.isAutoOpenComment = self.isAutoOpenComment
            
            // Is webview
            if let url = sender as? URL {
                destinationController.isActiveComment = false
                destinationController.url = url
                destinationController.isOpenLinkInNewView = isOpenLinkInNewView
                destinationController.isAutoOpenComment = url.valueOf(paramName: "open_comment") == "1" ? true : false
            }
            else{
                destinationController.webData = sender as? [String : Any]
            }
        }
        if segue.identifier == "showWKWebViewFromBrowser" {
            let destinationController = segue.destination as! WKWebViewController
            destinationController.delegate = self
            if let url = sender as? URL {
                destinationController.url = url
            }
        }
        if segue.identifier == "showShareFeedSegue" {
            let destinationController = segue.destination as! ShareFeedViewController
            if let data = sender as? [String:Any]{
                destinationController.webData = data
            }
        }
        
    }
    
    //check is add new
    override func viewWillAppear(_ animated: Bool) {
        self.isAutoOpenComment = false
        if self.isAddNew{
            doReload()
            self.isAddNew = false
        }
    }
    
    func checkAddNew(isAddNew: Bool) {
        self.isAddNew = isAddNew
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
                    self.performSegue( withIdentifier: "showPostFeedView", sender: json["data"])
                case "openComment":
                    self.isAutoOpenComment = true
                    self.performSegue( withIdentifier: "showCommentViewBrowser", sender: json["data"])
                case "openShareFeed":
                    self.performSegue( withIdentifier: "showShareFeedSegue", sender: json["data"])
                default : break
                    
                }
            }
        }
    }
    
    func commentIsAddNew(_ isAddNew: Bool){
        self.isAddNew = isAddNew
    }
}

extension URL {
    func valueOf(paramName: String) -> String? {
        
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == paramName })?.value
    }
}
