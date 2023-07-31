//
//  HomeTabBarViewController.swift
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

@objc
protocol HomeTabBarViewControllerDelegate {
    @objc optional func toggleLeftPanel()
    @objc optional func toggleRightPanel()
    @objc optional func collapseSidePanels()
    @objc optional func addGestureRecognizer()
    @objc optional func removeGestureRecognizer()
}
protocol HomeTabBarCommand{
    func execute() -> Bool
}
enum OpenWebCommandError: Error {
    case notWhatNewController
}
class OpenWebCommand:HomeTabBarCommand{
    let selfController : HomeTabBarViewController
    //let webController:WhatsNewViewController
    required init(selfController: HomeTabBarViewController) throws {
        self.selfController = selfController
        //webController = selfController.viewControllers![0] as! WhatsNewViewController
        
        if String(describing: type(of: selfController.viewControllers![0])) != "WhatsNewViewController" {
            throw   OpenWebCommandError.notWhatNewController
        }
        
    }
    func execute() -> Bool{
        selfController.selectedIndex = 0
        selfController.tabBar.tintColor = UIColor.gray
        //webController.delegateExt = selfController
        return true
    }
}
class HomeTabBarOperations{
    var openWebComand:OpenWebCommand?
    init(selfController: HomeTabBarViewController){
        do{
            openWebComand =  try OpenWebCommand(selfController: selfController)
        }catch OpenWebCommandError.notWhatNewController {
            
        }catch{
            
        }
    }
    func openWeb(){
        if (openWebComand?.execute())!{
            
        }
    }
}
class HomeTabBarViewController: UITabBarController,UITabBarControllerDelegate , SidePanelViewControllerDelegate,WhatsNewViewDelegate,AppHelperDelegate,UIPopoverPresentationControllerDelegate,OptionPoperverControllerDelegate{
    @IBOutlet weak var avatarBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var navTitleButton: UIButton!
    //let navTitleButton = UIButton(type:UIButtonType.custom)
    let WHATS_NEW_TAB = 0
    let NOTIFICATION_TAB = 1
    let MESSAGE_TAB = 2
    let MORE_TAB  = 3
    let avatarLoading:UIActivityIndicatorView = UIActivityIndicatorView()
    let avatarButton =  UIButton(type:UIButtonType.custom)
    var leftSearchBarButtonItem:UIBarButtonItem?
    var leftBackBarButtonItem:UIBarButtonItem?
    var leftBackWebBarButtonItem:UIBarButtonItem?
    var action = AppConstants.ACTION_DEFAULT_ON_HOME_TAB_BAR_CONTROLLER
    var actionParamater:AnyObject?
    var delegateExt : HomeTabBarViewControllerDelegate?
    var operations:HomeTabBarOperations?
    var meModel:UserModel?
    let animatedObject = TransitioningObject()
    let animatedBackObject = TransitioningBackObject()
    var previousTab = 0
    var currentTab = 0
    var isEnableBack = false
    let arrowImage = UIImage(named:"arrow.dropdown")
    var navSubData:AnyObject?
    var menuWhatNewFilter = [NSLocalizedString("items_whats_new_everyone",comment:"items_whats_new_everyone"),NSLocalizedString("items_whats_new_friends_me",comment:"items_whats_new_friends_me")]
    var optMenuWhatNewIsActived = 0
    // Hacking bugs
    var isEnableBackBarButtonItem = false
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        operations = HomeTabBarOperations(selfController: self)
        
        
    }
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        hacking()
        supportLocalizedAndStyle()
        addAvatarButton()
        addSearchButton()
        self.setNeedsStatusBarAppearanceUpdate()
        self.delegate = self
        AppHelperService.sharedInstance.homeTabbarDelegate = self
        
        
        //navigationItem.titleView = navTitleButton
        // Push Notification
        
        if AppConfigService.sharedInstance.isOpenedFromPushNotifications {
            AppConfigService.sharedInstance.isOpenedFromPushNotifications = false
            action = AppConstants.ACTION_ACTIVE_WEB_ON_WHATS_NEW_FROM_OUTSIDE
            WebViewService.sharedInstance.URLReload =  WebViewService.sharedInstance.pushNotificationURL! + "&access_token="+(SharedPreferencesService.sharedInstance.token?.access_token)!
            
            /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
             
             let initialViewController = storyboard.instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
             let aaaaaaa = storyboard.instantiateViewController(withIdentifier: "commentForm") as! CommentViewController
             // let aaaaa = storyboard.instantiateViewController(withIdentifier: "commentForm") as! CommentViewController
             //   initialViewController.performSegue(withIdentifier: "pushNotiSegue", sender: nil)
             //let url = URL(string: "http://localhost/moo_api/users/view/1?access_token=21d88257a8f4f644546770a0eca8dd669c7e4025")
             //initialViewController.performSegue(withIdentifier: "pushNotiSegue", sender: URL(string : "http://192.168.168.108/moo_api/users/view/1?access_token=21d88257a8f4f644546770a0eca8dd669c7e4025"))
             aaaaaaa.url = URL(string : "http://192.168.168.108/moo_api/users/view/1?access_token=21d88257a8f4f644546770a0eca8dd669c7e4025")
             initialViewController.pushViewController(aaaaaaa, animated: true)
             self.window?.rootViewController = initialViewController*/
        }
        // Hacking for restart application in case re-active app again by notification
        //    rule 1 : make sure the URLReload is moosite
        if WebViewService.sharedInstance.isAppCallFromNotificationURLAndTimeToReset {
            
            if WebViewService.sharedInstance.pushNotificationURL!.lowercased().range(of: AppConfigService.sharedInstance.getBaseURL() as String) != nil {
                
                if WebViewService.sharedInstance.pushNotificationURL!.lowercased().range(of: "?") != nil{
                    WebViewService.sharedInstance.URLReload =  WebViewService.sharedInstance.pushNotificationURL! + "&access_token="+(SharedPreferencesService.sharedInstance.token?.access_token)!
                }else{
                    WebViewService.sharedInstance.URLReload =  WebViewService.sharedInstance.pushNotificationURL! + "?access_token="+(SharedPreferencesService.sharedInstance.token?.access_token)!
                }
                
                WebViewService.sharedInstance.isAppCallFromNotificationURLAndTimeToReset = false
                action = AppConstants.ACTION_ACTIVE_WEB_ON_WHATS_NEW_FROM_NOTIFICATIONS
                
            }
            
        }
        
        
        switch action{
        case AppConstants.ACTION_DEFAULT_ON_HOME_TAB_BAR_CONTROLLER:
            //AppHelperService.sharedInstance.setTitle("What's New")
            let naviTitle = menuWhatNewFilter[optMenuWhatNewIsActived] + " ▾"
            setNavaigationTitle(naviTitle, dataSubmenu: menuWhatNewFilter as AnyObject)
            break
        case AppConstants.ACTION_ACTIVE_WEB_ON_WHATS_NEW_FROM_OUTSIDE,AppConstants.ACTION_ACTIVE_WEB_ON_WHATS_NEW_FROM_NOTIFICATIONS:
            let url = WebViewService.sharedInstance.pushNotificationURL!
            self.performSegue( withIdentifier: "showCommentView", sender: URL(string : url as String))
        default: break
            
        }
        NotificationService.sharedInstance.homeTabBarController = self
        
        
        
        _ = AlertService.sharedInstance.registerCurrentView(self)
        AppConfigService.sharedInstance.bootAfterLoadingHomeTabBar()
        
        
        // Config for pushing notifications
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        NotificationCenter.default.addObserver(self, selector: #selector(HomeTabBarViewController.updateRegistrationStatus(_:)),
                                               name: NSNotification.Name(rawValue: appDelegate.registrationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeTabBarViewController.showReceivedMessage(_:)),
                                               name: NSNotification.Name(rawValue: appDelegate.messageKey), object: nil)
        
        
    }
    
    func backTapped(_ sender:UIButton) {
        
        isEnableBack = true
        selectedIndex = previousTab
        disableBackButton()
        disableBackWebButton()
    }
    
    func setBackForTab(_ index:Int,hideButton:Bool=true){
        
        WebViewService.sharedInstance.historyURL = [URLRequest]()
        WebViewService.sharedInstance.ingnoreAddHistory = false
        isEnableBack = hideButton
        selectedIndex = WHATS_NEW_TAB
        previousTab = index
        tabBar.tintColor = UIColor.gray
    }
    func enableSearchButton(){
        navigationItem.leftBarButtonItems?.append(leftSearchBarButtonItem!)
    }
    func enableBackButton(){
        isEnableBackBarButtonItem = true
        navigationItem.leftBarButtonItems?.append(leftBackBarButtonItem!)
    }
    func enableBackWebButton(){
        navigationItem.leftBarButtonItems?.append(leftBackWebBarButtonItem!)
    }
    func disableSearchButton(){
        isEnableBackBarButtonItem = false
        navigationItem.leftBarButtonItems = navigationItem.leftBarButtonItems!.filter(){ $0 != leftSearchBarButtonItem
        }
    }
    func disableBackButton(){
        navigationItem.leftBarButtonItems = navigationItem.leftBarButtonItems!.filter(){ $0 != leftBackBarButtonItem
        }
    }
    func disableBackWebButton(){
        navigationItem.leftBarButtonItems = navigationItem.leftBarButtonItems!.filter(){ $0 != leftBackWebBarButtonItem
        }
    }
    func isBackButonExits()-> Bool{
        return isEnableBackBarButtonItem
    }
    func isSearchButonExits()-> Bool{
        let isExits = navigationItem.leftBarButtonItems!.filter(){ $0 == leftSearchBarButtonItem
        }
        if isExits.count > 0 {
            return true
        }
        return false
    }
    
    
    
    @IBAction func fillter(_ sender: AnyObject) {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertControllerStyle.actionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:"All Entries", style:UIAlertActionStyle.default, handler:{ action in
            
        }))
        settingsActionSheet.addAction(UIAlertAction(title:" My Entries", style:UIAlertActionStyle.default, handler:{ action in
            
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Friends' Entries", style:UIAlertActionStyle.default, handler:{ action in
            
        }))
        //settingsActionSheet.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.Cancel, handler:nil))
        
        settingsActionSheet.popoverPresentationController?.sourceView = view
        settingsActionSheet.popoverPresentationController?.sourceRect = sender.frame
        
        present(settingsActionSheet, animated: true, completion: nil)
    }
    func clickOnButton(_ sender: UIButton) {
        
        if navSubData != nil && navSubData!.count > 0 {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertControllerStyle.actionSheet)
            for case let data as [String:Any]  in navSubData as! NSArray {
                settingsActionSheet.addAction(UIAlertAction(title:data["label"] as? String, style:UIAlertActionStyle.default, handler:{ action in
                    let url = (AppConfigService.sharedInstance.getBaseURL() as String) + (data["url"] as! String)
                    WebViewService.sharedInstance.goURL(url)
                }))
            }
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.cancel, handler:nil))
            settingsActionSheet.popoverPresentationController?.sourceView = view
            settingsActionSheet.popoverPresentationController?.sourceRect = sender.frame
            
            present(settingsActionSheet, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        self.navigationController?.navigationBar.barTintColor = AppConfigService.sharedInstance.config.navigationBar_barTintColor
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        //disableBackButton()
        //disableSearchButton()
        previousTab = currentTab
        delegateExt?.addGestureRecognizer!()
        //print(selectedIndex)
        switch selectedIndex{
        case WHATS_NEW_TAB:
            currentTab = WHATS_NEW_TAB
            let naviTitle = menuWhatNewFilter[optMenuWhatNewIsActived] + " ▾"
            setNavaigationTitle(naviTitle, dataSubmenu: menuWhatNewFilter as AnyObject)
            //enableSearchButton()
            //WebViewService.sharedInstance.goHome()
            (viewController as! WhatsNewWKViewController).webView.scrollView.isScrollEnabled = true
            (viewController as! WhatsNewWKViewController).webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            (viewController as! WhatsNewWKViewController).doRefeshWebview()
        case NOTIFICATION_TAB:
            delegateExt?.removeGestureRecognizer!()
            currentTab = NOTIFICATION_TAB
            setNavaigationTitle(NSLocalizedString("tabbar_notifications",comment:"tabbar_notifications"), dataSubmenu: nil)
            NotificationService.sharedInstance.show()
            NotificationService.sharedInstance.me()
            
        case MESSAGE_TAB:
            //delegateExt?.removeGestureRecognizer!()
            currentTab = MESSAGE_TAB
            setNavaigationTitle(NSLocalizedString("tabbar_message",comment:"tabbar_message"), dataSubmenu: nil)
            MessageService.sharedInstance.show()
            NotificationService.sharedInstance.me()
            
        case MORE_TAB:
            currentTab = MORE_TAB
            setNavaigationTitle(NSLocalizedString("tabbar_more",comment:"tabbar_more"), dataSubmenu: nil)
        default:
            break
        }
        
        
        self.tabBar.tintColor = AppConfigService.sharedInstance.config.color_main_style
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func onTapTilteButton(_ sender: Any) {
        
        if currentTab == WHATS_NEW_TAB {
            // get a reference to the view controller for the popover
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popoverId") as! OptionPoperverController
            
            vc.modalPresentationStyle = .popover
            
            vc.menu = menuWhatNewFilter
            vc.optActived = optMenuWhatNewIsActived
            vc.delegateEx = self
            var height = 100;
            switch(vc.menu.count){
            case 1 :
                height = 50;
                break;
            case 2:
                height = 89;
                break;
            case 3 :
                height = 150;
                break;
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
    }
    // MARK: OptionPoperverControllerDelegate
    func menuPoperverSelected(_ key:Int){
        if currentTab == WHATS_NEW_TAB {
            optMenuWhatNewIsActived = key
            let naviTitle = menuWhatNewFilter[optMenuWhatNewIsActived] + " ▾"
            setNavaigationTitle(naviTitle, dataSubmenu: menuWhatNewFilter as AnyObject)
            let webController = self.viewControllers![0] as! WhatsNewWKViewController
            webController.setFilterForWebView(String(key))
        }
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    // Mark : SidePanelVIewDelage
    func menuSelected(_ key:String,url:String=""){
        self.selectedIndex=0
        self.tabBar.tintColor = UIColor.gray
        delegateExt?.collapseSidePanels!()

        switch key{
        case "profile_detail":
            let url = URL(string:url)
            self.performSegue( withIdentifier: "showWebBroswer", sender: url)
            break
        case "account_picture":
            self.performSegue( withIdentifier: "segueShowChangeProfilePicture", sender: self)
            break
        default:
            let url = URL(string:url)
            self.performSegue( withIdentifier: "showCommentView", sender: url)
        }
    }
    // Mark : WhatsNewViewDelage
    func openWeb() {
        
        if WebViewService.sharedInstance.URLReload != nil{
            WebViewService.sharedInstance.goURL(WebViewService.sharedInstance.URLReload!)
            WebViewService.sharedInstance.URLReload = nil
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowChangeProfilePicture" {
            let destinationController = segue.destination as! ChangeProfilePictureViewController
            destinationController.homeTabBarController = self
        }
        
        if segue.identifier == "showWebBroswer" {
            title = ""
            let destinationController = segue.destination as! WebViewBrowserController
            destinationController.url = sender as? URL
        }
        
        if segue.identifier == "showPostFeedView" {
            let destinationController = segue.destination as! PostFeedController
            destinationController.WhatsNewController = sender as? WhatsNewWKViewController
        }
        if segue.identifier == "showCommentView" {
            title = ""
            let destinationController = segue.destination as! CommentViewController
            // Is comment action
            if let data = sender as? [String:Any]{
                destinationController.webData = data
                destinationController.isActiveComment = true
            }
            // Is webview
            if let url = sender as? URL {
                destinationController.isActiveComment = false
                destinationController.url = url
            }
            destinationController.WhatsNewWKController = self.viewControllers![0] as? WhatsNewWKViewController
        }
        if segue.identifier == "showShareFeedSegue" {
            let destinationController = segue.destination as! ShareFeedViewController
            if let data = sender as? [String:Any]{
                destinationController.webData = data
            }
            destinationController.WhatsNewController = self.viewControllers![0] as? WhatsNewWKViewController
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if((fromVC.isKind(of: MoreViewController.self) || fromVC.isKind(of: NotificationsViewController.self) || fromVC.isKind(of: MessagesViewController.self)) && toVC.isKind(of: WhatsNewViewController.self)) {
            
            if isEnableBack {
                disableSearchButton()
                enableBackButton()
                isEnableBack = false
                
                return animatedObject
            }
            
        }
        if( fromVC.isKind(of: WhatsNewViewController.self) && (toVC.isKind(of: MoreViewController.self) || toVC.isKind(of: NotificationsViewController.self) || toVC.isKind(of: MessagesViewController.self)) ){
            if previousTab != WHATS_NEW_TAB && isEnableBack{
                isEnableBack = false
                return animatedBackObject
            }
            
        }
        return nil
    }
    
    // Mark : AppHelperDelegate
    func setNavaigationTitle(_ data:String,haveSubMenu:Bool=false,dataSubmenu:AnyObject?){
        var haveSubMenu = haveSubMenu
        self.title = data
        
        // Hide the feature : haveSubMenu
        haveSubMenu = false
        if !haveSubMenu {
            navTitleButton.setTitle(data, for: UIControlState())
            navTitleButton.setImage(nil, for: UIControlState())
            
            //navTitleButton.addTarget(nil, action: nil, for: UIControlEvents.touchUpInside)
            //navTitleButton.removeTarget(nil, action: nil, for: UIControlEvents.allTouchEvents)
        }else{
            /*
             navSubData = dataSubmenu
             navTitleButton.setTitle(data + " ", forState: UIControlState.Normal)
             navTitleButton.setImage(arrowImage, forState: UIControlState.Normal)
             navTitleButton.titleEdgeInsets = UIEdgeInsetsMake(0, -navTitleButton.imageView!.frame.size.width, 0, navTitleButton.imageView!.frame.size.width);
             navTitleButton.imageEdgeInsets = UIEdgeInsetsMake(0, navTitleButton.titleLabel!.frame.size.width, 0, -navTitleButton.titleLabel!.frame.size.width);
             navTitleButton.addTarget(self, action: Selector("clickOnButton:"), forControlEvents: UIControlEvents.TouchUpInside)
             */
        }
        
        
        
    }
    func showBackButton(){
        disableBackButton()
        disableBackWebButton()
        enableBackButton()
    }
    func hideBackButton(){
        disableBackButton()
    }
    func showBackWebButton() {
        //disableBackButton()
        disableBackWebButton()
        enableBackWebButton()
    }
    func hideBackWebButton() {
        disableBackWebButton()
    }
    
    
    
    // Mark :  Config for pushing notifications
    func updateRegistrationStatus(_ notification: Notification) {
        
        if let info = (notification as NSNotification).userInfo as? Dictionary<String,String> {
            if let error = info["error"] {
                AlertService.sharedInstance.process(error)
                
            } else if let _ = info["registrationToken"] {
                
                _ = "Check the xcode debug console for the registration token that you " +
                " can use with the demo server to send notifications to your device"
                //AlertService.sharedInstance.process(message)
                
            }
        } else {
            print("Software failure. Guru meditation.")
        }
    }
    
    func showReceivedMessage(_ notification: Notification) {
        
        
        if let info = (notification as NSNotification).userInfo as? Dictionary<String,AnyObject> {
            if let _ = info["aps"] as? Dictionary<String, String> {
                
                
                
                if AppConfigService.sharedInstance.isActivedFromPushNotifications || AppConfigService.sharedInstance.isOpenedFromPushNotifications{
                    
                    if let url = info["notification_url"] as? String {
                        WebViewService.sharedInstance.URLReload = url
                    }
                    
                    AppConfigService.sharedInstance.afterImplemitingOnTapFromPushNotification()
                }
                
                
                
            }
        } else {
            print("Software failure. Guru meditation.")
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
// Mark : Localized and style
extension HomeTabBarViewController{
    func supportLocalizedAndStyle(){
        // For debugging
        // print(SharedPreferencesService.sharedInstance.getCurrentSystemLanggaue())
        // print(NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!)
        // End debugging
        // Suppports NSLocalizedString
        
        let tabItems = self.tabBar.items! as [UITabBarItem]
        (tabItems[0] as UITabBarItem).title = NSLocalizedString("tabbar_whats_news",comment:"tabbar_whats_news")
        (tabItems[1] as UITabBarItem).title = NSLocalizedString("tabbar_notifications",comment:"tabbar_notifications")
        (tabItems[2] as UITabBarItem).title = NSLocalizedString("tabbar_message",comment:"tabbar_message")
        (tabItems[3] as UITabBarItem).title = NSLocalizedString("tabbar_more",comment:"tabbar_more")
        // End supports NSLocalizedString
        
        // Layout improvement
        tabBar.tintColor = AppConfigService.sharedInstance.config.color_main_style
        navTitleButton.setTitleColor(AppConfigService.sharedInstance.config.color_title, for: UIControlState())
    }
}
// Mark : Search button
extension HomeTabBarViewController{
    func addSearchButton(){
        // Left buttons config
        leftSearchBarButtonItem =  UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(HomeTabBarViewController.searchTapped(_:)))
        leftSearchBarButtonItem?.tintColor = AppConfigService.sharedInstance.config.color_title
        
        leftBackBarButtonItem = UIBarButtonItem(image: UIImage(named:"tabbar.back"),style:UIBarButtonItemStyle.plain, target: self, action: #selector(HomeTabBarViewController.backTapped(_:)))
        leftBackBarButtonItem?.tintColor = AppConfigService.sharedInstance.config.color_title
        
        leftBackWebBarButtonItem = UIBarButtonItem(image: UIImage(named:"tabbar.back"),style:UIBarButtonItemStyle.plain, target: self, action: #selector(HomeTabBarViewController.backWebTapped(_:)))
        leftBackWebBarButtonItem?.tintColor = AppConfigService.sharedInstance.config.color_title
        
        navigationItem.leftBarButtonItems = [leftSearchBarButtonItem!]
    }
    func backWebTapped(_ sender:UIButton){
        WebViewService.sharedInstance.goback()
    }
    func searchTapped(_ sender:UIButton) {
        
        self.performSegue(withIdentifier: "showSearchView",sender: self)
    }
}

// Mark : Avatar button
extension HomeTabBarViewController:AppServiceDelegate,ImageServiceAsynchronouslyDelegate{
    func addAvatarButton(){
        // Avatar button config
        avatarLoading.frame =  CGRect(x: 5, y: 5, width: 20,height: 20)
        avatarLoading.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        avatarLoading.hidesWhenStopped = true
        avatarLoading.startAnimating()
        
        //add function for button
        avatarButton.addTarget(self, action: #selector(HomeTabBarViewController.onTapAccount as (HomeTabBarViewController) -> () -> ()), for: UIControlEvents.touchUpInside)
        
        //set frame
        avatarButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        avatarButton.layer.cornerRadius = 3
        avatarButton.layer.borderWidth = 1
        avatarButton.layer.borderColor = UIColor.white.cgColor
        avatarButton.clipsToBounds = true
        avatarButton.addSubview(avatarLoading)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarButton)
        addAvatarButtonToNavigation()
    }
    func onTapAccount(){
        delegateExt?.toggleRightPanel!()
    }
    func addAvatarButtonToNavigation(){
        if meModel == nil {
            UserService.sharedInstance.registerCallback(self).me()
        }else{
            if let avatar  = meModel?.avatar as? [String:String]{
                
                if let url = avatar["100_square"] {
                    ImageService.sharedInstance.getAsynchronously(nil, url: url ,newWidth:CGFloat(),callback: self)
                }
            }
            
        }
        
    }
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        switch identifier {
        case "UserService.me.Success":
            meModel = UserService.sharedInstance.get()
            UserService.sharedInstance.unRegisterCallack(self)
            addAvatarButtonToNavigation()
            break
        default: break
        }
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        avatarButton.setImage(img,for: UIControlState())
        avatarLoading.stopAnimating()
    }
}

class TransitioningObject: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Get the "from" and "to" views
        let fromView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)
        
        //The "to" view with start "off screen" and slide left pushing the "from" view "off screen"
        toView.frame = CGRect(x: toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        let fromNewFrame = CGRect(x: -1 * fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            //toView.frame = CGRectMake(0, 0, 320, 560)
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            fromView.frame = fromNewFrame
        }, completion: { (Bool) -> Void in
            // update internal view - must always be called
            transitionContext.completeTransition(true)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}

class TransitioningBackObject: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Get the "from" and "to" views
        let fromView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)
        
        //The "to" view with start "off screen" and slide left pushing the "from" view "off screen"
        toView.frame = CGRect(x: -1 * toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        let fromNewFrame = CGRect( x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: { () -> Void in
                        //toView.frame = CGRectMake(0, 0, 320, 560)
                        toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
                        fromView.frame = fromNewFrame
        }, completion: { (Bool) -> Void in
            // update internal view - must always be called
            transitionContext.completeTransition(true)
        })
        
        
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}

// Mark Hacking
extension HomeTabBarViewController{
    func hacking(){
        // Hacking for UserTag and mentions for fixing the frienlist is missing on randoom when opening PostFeedContoller
        FriendService.sharedInstance.getRaw()
    }
}
