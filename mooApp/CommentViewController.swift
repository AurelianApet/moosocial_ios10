//
//  CommentControllerViewController.swift
//  mooApp
//
//  Created by duy on 6/1/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import UIKit
import WebKit
import TLPhotoPicker
import Photos
import NotificationBannerSwift

// protocol used for sending data back
protocol CommentDataDelegate: class {
    func commentIsAddNew(_ isAddNew: Bool)
}

class CommentViewController: AppViewController {
    
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var uiWebContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var UIWeb: UIView!
    @IBOutlet weak var usersMention: UITableView!
    
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    var webView: WKWebView!
    // used when is called by comment event from whatnewWK
    var webData:[String:Any]?
    var webUploadData:[String:Any]?
    // used when is called by click href from whatnewWK
    var url:URL?
    // used for refeshing WhatNewWk
    public var WhatsNewWKController: WhatsNewWKViewController?
    var mentionsListener:SZMentionsListener?
    public var filterString:String?
    var isActiveComment = false
    var isMentioning = false
    var isFirstLoad  = true
    var isOpenLinkInNewView = true
    var selectedAssets = [TLPHAsset]()
    var tmpRightBarButtons = [UIBarButtonItem]()
    var isUploadPhoto = false
    var banner:StatusBarNotificationBanner?
    var isAutoOpenComment = false
    var isLoadAnotherPage = false
    weak var delegate: CommentDataDelegate? = nil
    var isKeyboardShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initStyle()
        initKeyboard()
        initWKWebView()
        initMention()
        initUITableView()
        
        //check uato open comment
        if self.isAutoOpenComment{
            toggleComment()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initStyle(){
        self.navigationController?.navigationBar.tintColor = AppConfigService.sharedInstance.config.color_title
        //self.navigationItem.leftBarButtonItem?.tintColor = AppConfigService.sharedInstance.config.color_title
        self.tmpRightBarButtons = self.navigationItem.rightBarButtonItems!
        self.navigationItem.rightBarButtonItems = []
        if addButton != nil {
            addButton.tintColor = AppConfigService.sharedInstance.config.color_title
        }
        UIApplication.shared.isStatusBarHidden = false
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func onPost(_ sender: Any) {
        self.view.endEditing(true)
        let commentService = CommentService()
        
        if selectedAssets.count > 0 {
            for  asset in selectedAssets{
                commentService.images.append(asset.fullResolutionImage!)
            }
        }
        if webData != nil {
            
            if let object = webData?["objects"] as? [String:Any]{
                
                if (object["id"] as? String) != nil {
                    commentService.objectId = object["id"] as? String
                  
                }
                if let type = object["type"] as? String {
                    commentService.objectType = type
                    commentService.message = mentionsListener?.getTextWithMentionFormat()
                   
                }
                
            }
            if let action = webData?["action"] as? String{
                if action == "wall_post"{
                    commentService.objectType = "activity"
                }
            }
            commentService.registerCallback(self).post()
        }
        growingTextView.textView.text = ""
        selectedAssets = [TLPHAsset]()
    }
    
    @IBAction func onCamera(_ sender: Any) {
        self.isUploadPhoto = false
        loadPickImagesController()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        usersMention.isHidden = true
    }
    
    @IBAction func onAddButton(_ sender: Any) {
        if isAlbumsViewLink(){
            if webUploadData != nil {
                /*if let id = webUploadData?["id"] as? String {
                    let url = AppConfigService.sharedInstance.getBaseURL() + "/photo/photos/ajax_upload/Photo_Album/" + id
                    let goUrl = URL(string:SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo(url))
                    self.performSegue( withIdentifier: "showWKWebViewFromComment", sender: goUrl)
                    
                }*/
                self.isUploadPhoto = true
                loadPickImagesController()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // call this method on whichever class implements our delegate protocol
        self.delegate?.commentIsAddNew(self.isLoadAnotherPage ? true : false)
    }
}

// MARK: For WKWebview and Keybooard
extension CommentViewController:WKUIDelegate,WKNavigationDelegate ,WKScriptMessageHandler{
    func initKeyboard(){
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        growingTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        growingTextView.layer.borderWidth = 1.0
        growingTextView.layer.cornerRadius = 4
        //growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        growingTextView.textView.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        
        growingTextView.placeholderAttributedText = NSAttributedString(string: NSLocalizedString("comment_page_write_a_comment",comment:"comment_page_write_a_comment"),
                                                                       attributes: [NSFontAttributeName: self.growingTextView.textView.font!,
                                                                                    NSForegroundColorAttributeName: UIColor.gray
            ]
        )
        
        updateWebContainerBottomConstant()
        
        
    }
    func initWKWebView(){
        
        let wkConfig = WKWebViewConfiguration()
        wkConfig.userContentController.add(self,name: "action")
        webView = WKWebView(frame: UIWeb.frame, configuration: wkConfig)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
        webView.navigationDelegate = self
        //self.automaticallyAdjustsScrollViewInsets = false
        addPullToRefreshToWebView()
        UIWeb.addSubview(webView)
        loadWebContent()
        if isActiveComment {
            self.growingTextView.textView.becomeFirstResponder()
            showComment()
        }else{
            hideComment()
        }
    }
    func loadWebContent(){
        var currentURL = "";
        // actived by comment event on WhatNew webview
        if webData != nil {
            if let objects = webData?["objects"] as? [String:Any]{
                if let url = objects["url"] as? String {
                    currentURL = url
                    
                }
            }
        }
        // actived by link web on WhatNew webview 
        if url != nil {
            //let myRequest = URLRequest(url: url!)
            currentURL = (url?.absoluteString)!
        }
        
        if currentURL != ""{
            let myRequest = URLRequest(url: URL(string:SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo(currentURL))!)
            webView.load(myRequest)
        }
    }
    
    
    /*!  adding the pull refesh in wkwebview
     */
    func addPullToRefreshToWebView(){
        let refreshController:UIRefreshControl = UIRefreshControl()
        
        refreshController.addTarget(self, action: #selector(WhatsNewViewController.refreshWebView(_:)), for: UIControlEvents.valueChanged)
        //refreshController.attributedTitle = NSAttributedString(string: "Pull down to refresh...")
        refreshController.tintColor = UIColor.lightGray
        webView.scrollView.addSubview(refreshController)
        
    }
    /*!  the callback for pull refesh action
     */
    func refreshWebView(_ refresh:UIRefreshControl){
        doRefeshWebview()
        refresh.endRefreshing()
    }
    func doRefeshWebview(){
        isFirstLoad = true
        initStyle()
        webView.reload()
    }
    func toggleComment(){
        if inputContainerView.isHidden {
            showComment()
        }else{
            hideComment()
        }
    }
    func toggleAddButton(){
        if navigationItem.rightBarButtonItems! == []{
            navigationItem.rightBarButtonItems = tmpRightBarButtons
        }else{
            navigationItem.rightBarButtonItems = []
        }
    }
    func hideComment(){
        inputContainerView.isHidden = true
        updateWebContainerBottomConstant()
    }
    func showComment(){
        inputContainerView.isHidden = false
        updateWebContainerBottomConstant()
    }
    func getHeightInputContainerView()-> CGFloat{
        if self.inputContainerView.isHidden {
            return 0
        }else{
            return inputContainerView.frame.size.height
        }
    }
    func keyboardWillHide(_ sender: Notification) {
        self.isKeyboardShow = false
        var keyboardHeight : CGFloat = 0
        if let userInfo = (sender as NSNotification).userInfo {
            if let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                keyboardHeight = kbHeight
                //key point 0,
                self.inputContainerViewBottom.constant =  0
                //textViewBottomConstraint.constant = keyboardHeight
                updateWebContainerBottomConstant()
                //UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
                
            }
        }
        
        //set mention position
        decideMentionPosition(keyboardHeight)
    }
    func keyboardWillShow(_ sender: Notification) {
        self.isKeyboardShow = true
        var keyboardHeight : CGFloat = 0
        if(!self.inputContainerView.isHidden){
            if let userInfo = (sender as NSNotification).userInfo {
                if let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                    keyboardHeight = kbHeight
                    self.inputContainerViewBottom.constant = kbHeight
                    //UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded()})
                    updateWebContainerBottomConstant()
                }
            }
        }
        
        //set mention position
        decideMentionPosition(keyboardHeight)
    }
    func updateWebContainerBottomConstant(){
        uiWebContainerViewBottom.constant = inputContainerViewBottom.constant + getHeightInputContainerView()
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        if let json = message.body as? [String: Any] {
            if let command = json["command"] as? String{
                
                switch(command) {
                case "openComment"  :
                    toggleComment()
                    if let data = json["data"] as? [String : Any]{
                        webData = data
                        //showComment()
                        if inputContainerView.isHidden {
                            self.view.endEditing(true)
                        }else{
                            self.growingTextView.textView.becomeFirstResponder()
                        }
                        
                    }
                case "enableUploadPhoto":
                    if let data = json["data"] as? [String : Any]{
                        toggleAddButton()
                        webUploadData =  data
                    }
                case "openShareFeed":
                    if let data = json["data"] as? [String : Any]{
                        self.performSegue( withIdentifier: "showShareFeedSegue", sender: data)
                    }
                   
                default:
                    break
                }
            }
        }
    }
    /*! the config for openning all links in activies to new WKWebview view
     */

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !isFirstLoad{
            if webView.url != nil{
                let link = URL(string:SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo((webView.url?.absoluteString)!))!
                isFirstLoad = true
                self.isLoadAnotherPage = true
                let myRequest = URLRequest(url: link)
                if isPhotoViewLink(link.absoluteString){
                    self.navigationItem.rightBarButtonItems = nil
                    self.isLoadAnotherPage = false
                }
                webView.load(myRequest)
            }
        }
    }
    
    func isPhotoViewLink(_ url: String)-> Bool{
        if url.range(of: "photos/view") != nil{
            return true
        }
        return false
    }
    
    // Fix for double tab when openning 
    // - Detail Video 
    // - Create new blog 
    // - Create new
    func isSpecialLink(_ url:String)-> Bool{
        if url.lowercased().range(of:"youtube.com") != nil {
            return true
        }
        if url.lowercased().range(of:"about:blank") != nil {
            return true
        }
        if url.lowercased().range(of:"photos/view") != nil {
            return true
        }
        
        return false
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.title = webView.title
        if isActiveComment {
            webView.evaluateJavaScript("window.commentAction.refeshAndScrollToBottom();") { (result, error) in
                print(result as Any);
                if error != nil {
                    print(result as Any)
                }
            }
        }
        if isFirstLoad {
            isFirstLoad = false
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showWKWebViewFromComment" {
            let destinationController = segue.destination as! WKWebViewController
            destinationController.url = sender as? URL
        }
        else if segue.identifier == "showShareFeedSegue" {
            let destinationController = segue.destination as! ShareFeedViewController
            if let data = sender as? [String:Any]{
                destinationController.webData = data
            }
        }
        
    }
    func isAlbumsViewLink()->Bool{
        if let url = webView.url?.absoluteString {
            return _isAblbumViewLink(url)
        }
        return false
    }
    func _isAblbumViewLink(_ url:String)->Bool{ 
        if(url.range(of: "albums/view") != nil){
            return true
        }
        return false
    }
    
    func isProfileLink(_ url:String)->Bool{
        return url.range(of:"users/view") != nil
    }
    
    func isNotificationLink(_ url:String)->Bool{
        return url.range(of:"notifications/ajax_view") != nil
    }
    
    func isCreateAlbumLink(_ url:String)->Bool{
        return url.range(of:"photo/albums/create") != nil
    }
}
// Mark : Mention
extension CommentViewController:SZMentionsManagerProtocol,UITextViewDelegate{
    func initMention(){
        mentionsListener = SZMentionsListener(mentionTextView: growingTextView.textView,
                                              mentionsManager: self, textViewDelegate: self, mentionTextAttributes: mentionAttributes(), defaultTextAttributes: defaultAttributes(),spaceAfterMention: true, addMentionOnReturnKey: true)
        
        //set mention position
        decideMentionPosition()
    }
    private func mentionAttributes() -> [SZAttribute] {
        var attributes = [SZAttribute]()
        
        let attribute = SZAttribute(
            attributeName: NSForegroundColorAttributeName,
            attributeValue: UIColor.black)
        let attribute2 = SZAttribute(
            attributeName: NSFontAttributeName,
            attributeValue: UIFont.systemFont(ofSize: 14.0)) //UIFont(name: "ChalkboardSE-Bold", size: 12)!)
        let attribute3 = SZAttribute(
            attributeName: NSBackgroundColorAttributeName,
            attributeValue: UIColor.lightGray)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)
        
        return attributes
    }
    private func defaultAttributes() -> [SZAttribute] {
        var attributes = [SZAttribute]()
        
        let attribute = SZAttribute(
            attributeName: NSForegroundColorAttributeName,
            attributeValue: UIColor.gray)
        let attribute2 = SZAttribute(
            attributeName: NSFontAttributeName,
            attributeValue: UIFont.systemFont(ofSize: 14.0))//UIFont(name: "ArialMT", size: 12)!)
        let attribute3 = SZAttribute(
            attributeName: NSBackgroundColorAttributeName,
            attributeValue: UIColor.white)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)
        
        return attributes
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    func textViewDidChange(_ textView: UITextView) {
        if growingTextView.textView.text.isEmpty {
            postButton.isEnabled = false
        }else{
            postButton.isEnabled = true
        }
        
        //set mention position
        decideMentionPosition()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func decideMentionPosition(_ keyboardHeight: CGFloat = 0){
        usersMention.frame = inputContainerView.frame
        var maxUserDisplay = mentionsList().count
        if mentionsList().count > 3{
            maxUserDisplay = 3
        }
        var tableHeight:CGFloat = CGFloat(44 * maxUserDisplay)
        if( tableHeight > UIWeb.frame.size.height){
            tableHeight = UIWeb.frame.size.height
        }
        usersMention.frame.size.height = tableHeight
        
        if self.isKeyboardShow {
            usersMention.frame.origin.y = inputContainerView.frame.origin.y - tableHeight - keyboardHeight
        }
        else{
            usersMention.frame.origin.y = inputContainerView.frame.origin.y - tableHeight + keyboardHeight
        }
    }
    
    func filter(_ string: String?) {
        filterString = string
        if isMentioning {
            usersMention.isHidden = false
        }else{
            usersMention.isHidden = true
        }
        
        usersMention.reloadData()
        
    }
    func mentionsList() -> [SZUserMention] {
        
        //var filteredMentions = mentions
        if filterString != nil{
            if  let filteredMentions = FriendService.sharedInstance.getMentions(filterString!) {
                return filteredMentions
            }
        }
        
        return [SZUserMention]()
        
        
    }
    func showMentionsListWithString(_ mentionsString: String) {
        isMentioning = true
        filter(mentionsString)
    }
    func hideMentionsList() {
        isMentioning = false
        filter(nil)
        
    }
    func addMention(_ mention: SZUserMention) {
        mentionsListener!.addMention(mention)
    }
    func shouldAddMentionOnReturnKey(){
        
    }
}
// MARK: Pick image 
extension CommentViewController:TLPhotosPickerViewControllerDelegate{
    func loadPickImagesController(){
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        if self.isUploadPhoto == false{ //only limit 1 image for comment
            configure.maxSelectedAssets = 1
        }
        else{
            configure.doneTitle = NSLocalizedString("album_photo_upload",comment:"album_photo_upload")
        }
        configure.nibSet = (nibName: "CustomCell_Instagram", bundle: Bundle.main)
        configure.allowedVideo = false
        configure.allowedLivePhotos = false
        configure.usedCameraButton = true
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        self.present(viewController, animated: true, completion: nil)
    }
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets

        //save album photo
        if selectedAssets.count > 0 && self.isUploadPhoto == true{
            let albumPhotoService = AlbumPhotoService()
            for  asset in selectedAssets{
                albumPhotoService.inputImages.append(asset.fullResolutionImage!)
            }
            albumPhotoService.target_id = Int((self.webUploadData?["id"] as? String)!)!
            albumPhotoService.registerCallback(self).doPost()
        }
    }
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        // if you want to used phasset.
    }
    func photoPickerDidCancel() {
        // cancel
    }
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        self.showAlert(vc: picker)
    }
    func showAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "Exceed Maximum Number Of Selection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        
        return thumbnail
        
    }
}
// MARK:  AppServiceDelegate
extension CommentViewController:AppServiceDelegate{
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        switch identifier {
        case "CommentService.post.Success":
            webView.evaluateJavaScript("window.commentAction.refeshAndScrollToBottom();") { (result, error) in
                print(result as Any);
                if error != nil {
                    print(result as Any)
                }
            }
            if WhatsNewWKController != nil {
                WhatsNewWKController?.doRefeshWebview()
            }
        case "PhotoService.album.savephoto.Success":
            doRefeshWebview()
            selectedAssets = [TLPHAsset]()
        case "PhotoService.album.savephoto.Failure":
            alert(NSLocalizedString("album_photo_post_failure",comment:"album_photo_post_failure"))
        default:
            break
        }
    }
}
// MARK: UITable Delegate
extension CommentViewController:UITableViewDelegate,UITableViewDataSource{
    func initUITableView(){
        usersMention.delegate = self
        usersMention.dataSource=self
        usersMention.alwaysBounceVertical = false
        
        
        // Add line for first row
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x:0,y:0, width:usersMention.frame.size.width, height:px)
        let line = UIView(frame: frame)
        usersMention.tableHeaderView = line
        line.backgroundColor = usersMention.separatorColor
        // Set it at bottom of view
        usersMention.frame = CGRect(x:view.frame.origin.x,y:view.frame.size.height - 90,width:view.frame.size.width,height:90)
        usersMention.isHidden = true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionsList().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for:indexPath) as! UserCommentCellController
        
        cell.textLabel?.text = mentionsList()[indexPath.row].szMentionName
        
         if mentionsList()[indexPath.row].szMentionAvatar != ""{
         let _ = cell.setUserAvatar(mentionsList()[indexPath.row].szMentionAvatar)
         }
         
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.addMention(mentionsList()[indexPath.row])
    }
}

class UserCommentCellController:UITableViewCell,ImageServiceAsynchronouslyDelegate{
    func setUserAvatar(_ avatarUrl:String?)->Bool{
        if avatarUrl != ""{
            ImageService.sharedInstance.getAsynchronously(self.imageView,url: avatarUrl!,newWidth:CGFloat(AppConstants.MOO_SOCIAL_IMAGE_CELL_WIDTH),callback: self)
            return true
        }
        
        return false
    }
    
    func doAfterGetAsynchronously(_ img:UIImage?){
        
    }
}
