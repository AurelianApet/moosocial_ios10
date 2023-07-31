//
//  PostFeedController.swift
//  mooApp
//
//  Created by duy on 4/14/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import UIKit
import TLPhotoPicker
import Photos
class PostFeedController:UIViewController, SelectListDataDelegate  {
    
    @IBOutlet var menuAddToYourPost: UITableView!
    
    @IBOutlet weak var menuActionAdd: UITableView!
    @IBOutlet weak var WYMTextView: UITextView!
    
    @IBOutlet weak var postImageScroll: UICollectionView!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var optPrivacy: UIButton!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    // Fetch-link ui
    @IBOutlet weak var fetchLinkView: UIView!
    @IBOutlet weak var imageFLView: UIImageView!
    @IBOutlet weak var titleFLView: UILabel!
    @IBOutlet weak var desFLView: UILabel!
    var fetchLink:String?
    // End fetch-link ui
    // Used for privacy option
    var menuPrivacy = [NSLocalizedString("items_whats_new_everyone",comment:"items_whats_new_everyone"),NSLocalizedString("items_whats_new_friends_me",comment:"items_whats_new_friends_me")]
    var optMenuPrivacyIsActived = 0
    
    // Used for image picked
    var WhatsNewController: WhatsNewWKViewController?
    var selectedAssets = [TLPHAsset]()
    
    // @mention
    var meModel:UserModel?
    var mentionsListener:SZMentionsListener?
    public var isMentioning:Bool = false
    public var listener: SZMentionsListener?
    
    public var filterString: String?
    public var isFriendsLoading:Bool = false
    public var keyboardHeight:CGFloat?
    // End @mention
    public var userTagging:[Int] = []
    public var gPaddingLeft:CGFloat?
    override func viewDidLoad() {
        initStyle()
        super.viewDidLoad()
        initPrivacyButton()
        initUITableView()
        initTextView()
        initFetchLinkView()
        initImageCollectView()
        updateAvatarAndName()
    }
    func initStyle(){
        // Suppports NSLocalizedString
        navigationItem.title = NSLocalizedString("post_feeds_page_title",comment:"post_feeds_page_title")
        // End supports NSLocalizedString
        self.navigationController?.navigationBar.tintColor = AppConfigService.sharedInstance.config.color_title
        gPaddingLeft = avatar.frame.origin.x
    }
    //get user tagging from delegate
    func getSelectedItems(selectedIds: [Int], selectedItems: [SelectListModel]) {
        self.userTagging = selectedIds
    }
    
    @IBAction func onTouchPrivacyOpt(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popoverId") as! OptionPoperverController
        
        vc.modalPresentationStyle = .popover
        
        vc.menu = menuPrivacy
        vc.optActived = optMenuPrivacyIsActived
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
    
    @IBAction func onCancel(_ sender: Any) {
        navigationController!.popViewController(animated: true)
    }
 
    @IBAction func onPost(_ sender: Any) {
        
        let activityService = ActivityService()
        if selectedAssets.count > 0 {
            for  asset in selectedAssets{
                activityService.images.append(asset.fullResolutionImage!)
            }
        }
        
        activityService.message = mentionsListener?.getTextWithMentionFormat()
        activityService.messageText = WYMTextView.text
        activityService.WhatsNewWKController = self.WhatsNewController
        activityService.privacy = optMenuPrivacyIsActived + 1
        activityService.userTaging = self.userTagging
        if isFetchLinkShowed() {
            activityService.userShareLink = self.fetchLink
        }
        activityService.post()
        navigationController!.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        self.showUserTagged()
        FriendService.sharedInstance.getMentions("", true)!
    }
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardHeight == nil {
                keyboardHeight = keyboardSize.height
            }
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserTagView" {
            let destinationController = segue.destination as! SelectListController
            
            //load user list
            let users:[SZUserMention] = FriendService.sharedInstance.getMentions()!
            var itemList : [SelectListModel] = []
            if users.count > 0{
                for user in users{
                    let item = SelectListModel()
                    item.setData(id : user.szMentionId, avatar: user.szMentionAvatar, name: user.szMentionName)
                    itemList.append(item)
                }
            }
            
            //prepare data for select list view
            destinationController.setItemList(itemList : itemList)
            destinationController.selectedIds = self.userTagging
            destinationController.delegate = self
        }
    }
    
    //show user tagged
    func showUserTagged(){
        self.name.numberOfLines = 0;
        let users : [SZUserMention] = FriendService.sharedInstance.getMentions()!
        let userTagging = self.userTagging
        let meModel = UserService.sharedInstance.get()
        var taggingText = ""
        var taggingHightlightFrist = ""
        var taggingHightlightLast = ""
        if userTagging.count == 1{
            var userName = ""
            for  user in users{
                if userTagging[0] == user.szMentionId{
                    userName = user.szMentionName
                    break
                }
            }
            
            //save text to set color
            taggingHightlightFrist = userName
            
            //set tagging text for label
            taggingText = NSLocalizedString("post_feeds_tag_with",comment:"post_feeds_tag_with") + userName
            
            self.name.text = (meModel?.name)! + taggingText
        }
        else if userTagging.count == 2{
            var userName = ""
            var userName2 = ""
            for  user in users{
                if userTagging[0] == user.szMentionId{
                    userName = user.szMentionName
                }
                if userTagging[1] == user.szMentionId{
                    userName2 = user.szMentionName
                }
            }
            
            //save text to set color
            taggingHightlightFrist = userName
            taggingHightlightLast = userName2
            
            //set tagging text for label
            taggingText = NSLocalizedString("post_feeds_tag_with",comment:"post_feeds_tag_with") + userName + NSLocalizedString("post_feeds_tag_and",comment:"post_feeds_tag_and") + userName2
            
            
            self.name.text = (meModel?.name)! + taggingText
        }
        else if userTagging.count > 2{
            var userName = ""
            for  user in users{
                if userTagging[0] == user.szMentionId{
                    userName = user.szMentionName
                }
            }
            
            //count other users
            let otherUserCount : Int = (userTagging.count - 1)
            
            //save text to set color
            taggingHightlightFrist = userName
            taggingHightlightLast = String(otherUserCount) + NSLocalizedString("post_feeds_tag_others",comment:"post_feeds_tag_others")
            
            //set tagging text for label
            taggingText = NSLocalizedString("post_feeds_tag_with",comment:"post_feeds_tag_with") + userName + NSLocalizedString("post_feeds_tag_and",comment:"post_feeds_tag_and") + String(otherUserCount) + NSLocalizedString("post_feeds_tag_others",comment:"post_feeds_tag_others")
            
            self.name.text = (meModel?.name)! + taggingText
        }
        else{
            self.name.text = (meModel?.name)!
        }
        
        //set color for tagging text
        let myMutableString = NSMutableAttributedString(string: self.name.text!, attributes: [NSFontAttributeName:UIFont(name: self.name.font.fontName, size: self.name.font.pointSize)!])
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13.0)]
        let myLabel = self.name.text! as NSString
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: AppConfigService.sharedInstance.config.navigationBar_barTintColor, range: myLabel.range(of: taggingHightlightFrist))
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: AppConfigService.sharedInstance.config.navigationBar_barTintColor, range: myLabel.range(of: taggingHightlightLast))
        myMutableString.addAttributes(boldFontAttribute, range: myLabel.range(of: taggingText))
        self.name.attributedText = myMutableString
        
        //change wymtextview contrant
        var lineCount: Int = 0
        let textSize = CGSize(width: CGFloat(self.name.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.name.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.name.font.lineHeight))
        lineCount = rHeight / charSize
        
        for constraint in self.view.constraints where (constraint.identifier == "WYMText.top") {
            self.WYMTextView.setContentOffset(CGPoint.zero, animated: false)
            if lineCount == 2{
                constraint.constant = 20
            }
            else {
                constraint.constant = 8
            }
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
            self.WYMTextView.layoutIfNeeded()
            break
        }
    }
}
// MARK: KeyBoard custom
extension PostFeedController:UITextViewDelegate{
    func initTextView(){
        menuAddToYourPost.delegate = self
        menuAddToYourPost.dataSource = self
        //menuAddToYourPost.reloadData()
        setScrollMenuAddToYourPost(enable: false)
        menuAddToYourPost.tableFooterView = UIView(frame: CGRect(x:0,y:0, width:menuAddToYourPost.frame.size.width, height:1))
       
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x:0,y:0, width:menuAddToYourPost.frame.size.width, height:px)
        let line = UIView(frame: frame)
        menuAddToYourPost.tableHeaderView = line
 
        line.backgroundColor = menuAddToYourPost.separatorColor
        
        WYMTextView.inputAccessoryView = menuAddToYourPost
        WYMTextView.delegate = self
        initMention()
        WYMTextView.text = NSLocalizedString("post_feeds_page_title",comment:"post_feeds_page_title")
        WYMTextView.textColor = UIColor.lightGray
       
        postButton.isEnabled = false
    }
    func setScrollMenuAddToYourPost(enable:Bool){
        menuAddToYourPost.alwaysBounceVertical = enable
        menuAddToYourPost.isScrollEnabled = enable
        
        if( WYMTextView.inputAccessoryView != nil){
            
            if( (WYMTextView.inputAccessoryView?.constraints.count)! > 0){
                if(enable){
                    let screenHeight = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.height + view.frame.size.height
                    (WYMTextView.inputAccessoryView?.constraints[0])?.constant = screenHeight - keyboardHeight! + 50
                }else{
                    (WYMTextView.inputAccessoryView?.constraints[0])?.constant = 45
                }
            }
            
        }
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.WYMTextView.layoutIfNeeded()
        if WYMTextView.textColor == UIColor.lightGray {
            WYMTextView.text = nil
            WYMTextView.textColor = UIColor.black
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            postButton.isEnabled = false
            
            if selectedAssets.count > 0{
                postButton.isEnabled = true
            }
        }else{
            postButton.isEnabled = true
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if WYMTextView.text.isEmpty {
            WYMTextView.text = NSLocalizedString("post_feeds_page_title",comment:"post_feeds_page_title")
            WYMTextView.textColor = UIColor.lightGray
        }
    }
    
    func getNumberOfMenuAddToYourPostForTableView()->Int{
        return 1
    }
    func getCellForMenuAddToYourPost(_ tableView:UITableView)->UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
    
        // set the text from the data model
        cell.textLabel?.text = NSLocalizedString("post_feeds_add_to_your_post",comment:"post_feeds_add_to_your_post")
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    func getNumberOfMenuActionAddForTableView()->Int{
        if isFetchLinkShowed(){
            return 1
        }
        return 2
    }
    func getCellForMenuActionAdd(_ tableView:UITableView,cellForRowAt indexPath: IndexPath)->UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("post_feeds_tag_friends",comment:"post_feeds_tag_friends")
            cell.imageView?.image = "👤".image()
        case 1:
            cell.textLabel?.text = NSLocalizedString("post_feeds_photo",comment:"post_feeds_photo")
            cell.imageView?.image = "📷".image()
            
        default:
            break
        }
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
}
// MARK: UITable Delegate
extension PostFeedController:UITableViewDelegate,UITableViewDataSource{
    func initUITableView(){
        menuActionAdd.delegate = self
        menuActionAdd.dataSource = self
        menuActionAdd.reloadData()
        menuActionAdd.alwaysBounceVertical = false
        menuActionAdd.isScrollEnabled = false
        
        // Add line for first row
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x:0,y:0, width:menuActionAdd.frame.size.width, height:px)
        let line = UIView(frame: frame)
        menuActionAdd.tableHeaderView = line
        line.backgroundColor = menuActionAdd.separatorColor
        // Set it at bottom of view
        if isFetchLinkShowed(){
            menuActionAdd.frame = CGRect(x:view.frame.origin.x,y:view.frame.size.height - 45,width:view.frame.size.width,height:45)
        }
        else {
            menuActionAdd.frame = CGRect(x:view.frame.origin.x,y:view.frame.size.height - 90,width:view.frame.size.width,height:90)
        }
       
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // callbacked for add to your post menu
        if(tableView == menuAddToYourPost){
            if(!isMentioning){
                return getNumberOfMenuAddToYourPostForTableView()
            }else{
                return getNumberOfMentionsForTableView()
            }
            
        }
        // callbacked for action add menu
        if(tableView == menuActionAdd){
            return getNumberOfMenuActionAddForTableView()
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == menuAddToYourPost){
            // create a new cell if needed or reuse an old one
            if(!isMentioning){
                return getCellForMenuAddToYourPost(tableView)
            }else{
                return getCellForMentions(tableView,cellForRowAt: indexPath)
            }
            
        }
        
        if(tableView == menuActionAdd){
            return getCellForMenuActionAdd(tableView,cellForRowAt: indexPath)
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == menuAddToYourPost){
            if(!isMentioning){
                self.view.endEditing(true)
            }else{
                self.addMention(mentionsList()[indexPath.row])
            }
        }
        if(tableView == menuActionAdd){
            switch indexPath.row {
            case 0:
                self.performSegue( withIdentifier: "showUserTagView", sender: self)
            case 1:
                loadPickImagesController()
                
            default:
                break
            }
        }
        
    }
}
// MARK: Avatar button , usernmae
extension PostFeedController:AppServiceDelegate,ImageServiceAsynchronouslyDelegate{
    
    func updateAvatarAndName(){ 
        if meModel == nil {
            UserService.sharedInstance.registerCallback(self).me()
        }else{
            if let avatar  = meModel?.avatar as? [String:String]{
                
                if let url = avatar["100_square"] {
                    ImageService.sharedInstance.getAsynchronously(self.avatar, url: url ,newWidth:CGFloat(),callback: self)
                }
                
            }
            if let name = meModel?.name {
                self.name.text = name
            }
            
        }
        
    }
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        switch identifier {
        case "UserService.me.Success":
            meModel = UserService.sharedInstance.get()
            UserService.sharedInstance.unRegisterCallack(self)
            updateAvatarAndName()
        case "FriendService.get.Success":
            isFriendsLoading = false
            menuAddToYourPost.reloadData()
        case "FriendService.before.get":
            isFriendsLoading = true
        case "ActivityService.Before.FetchLink":
            startLoadingFetchLink()
        case "ActivityService.FetchLink.Success":
            if !isShowImageCollectView(){
                fetchLinkCallback(data)
            }
            
        default: break
        }
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        //avatar.setImage(img,for: UIControlState())
    }
}
// MARK: OptionPoperverControllerDelegate
extension PostFeedController:UIPopoverPresentationControllerDelegate,OptionPoperverControllerDelegate{
    func initPrivacyButton(){
        let naviTitle = menuPrivacy[optMenuPrivacyIsActived] + " ▾"
        optPrivacy.setTitle(naviTitle, for: .normal)
        optPrivacy.backgroundColor = .clear
        optPrivacy.layer.cornerRadius = 5
        optPrivacy.layer.borderWidth = 1
        optPrivacy.layer.borderColor = UIColor.gray.cgColor
        optPrivacy.setTitleColor(UIColor.gray, for: .normal)
        optPrivacy.contentEdgeInsets = UIEdgeInsetsMake(5,5,5,5)
    }
    func menuPoperverSelected(_ key:Int){
        optMenuPrivacyIsActived = key
        let naviTitle = menuPrivacy[optMenuPrivacyIsActived] + " ▾"
        optPrivacy.setTitle(naviTitle, for: .normal)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
// MARK: Mention
extension PostFeedController:SZMentionsManagerProtocol{
    func initMention(){
        mentionsListener = SZMentionsListener(mentionTextView: WYMTextView,
                                                  mentionsManager: self, textViewDelegate: self, mentionTextAttributes: mentionAttributes(), defaultTextAttributes: defaultAttributes(),spaceAfterMention: true, addMentionOnReturnKey: true)
        //WYMTextView.delegate = mentionsListener
        /*WYMTextView.text = "Test Steven Zweier mention"
        WYMTextView.delegate = mentionsListener
        let mention = SZUserMention()
        mention.szMentionName = "Steven Zweier"
        mention.szMentionRange = NSRange(location: 5, length: 13)
        mentionsListener.insertExistingMentions([mention])*/
        
    }
    func filter(_ string: String?) {
        filterString = string
        menuAddToYourPost.reloadData()
    }
    func mentionsList() -> [SZUserMention] {
        
        
        //var filteredMentions = mentions
       
        if  let filteredMentions = FriendService.sharedInstance.getMentions(filterString!) {
            
            let selectedIds : [Int] = (mentionsListener?.getSelectedMentionUserId())!
            var tempMentionList = [SZUserMention]()
            
            for user in filteredMentions{
                if !selectedIds.contains(user.szMentionId) { //except selected user
                    tempMentionList.append(user)
                }
            }
            return tempMentionList
        }
        
        return [SZUserMention]()
        
        
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
    func showMentionsListWithString(_ mentionsString: String) {
        isMentioning = true
        setScrollMenuAddToYourPost(enable: true)
        filter(mentionsString)
        makeAvatarNamePrivacyHidden(status: true)
        
        //set WYMTextView position
        let topHeight = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.height
        self.WYMTextView.frame = CGRect(x: self.WYMTextView.frame.origin.x, y: topHeight, width:self.WYMTextView.frame.size.width,height: 20)
    }
    
    func hideMentionsList() {
        makeAvatarNamePrivacyHidden(status: false)
        isMentioning = false
        setScrollMenuAddToYourPost(enable: false)
        filter(nil)
        self.showUserTagged()
    }
    func makeAvatarNamePrivacyHidden(status:Bool){
        avatar.isHidden = status
        optPrivacy.isHidden = status
        name.isHidden = status
    }
    func addMention(_ mention: SZUserMention) {
        mentionsListener!.addMention(mention)
    }
    //**Optional function Called when user tap Return key you must init SZMentionsListener with addMentionOnReturnKey = true
    func shouldAddMentionOnReturnKey() {
        //if let mention = dataManager?.firstMentionObject() {
        //    dataManager?.addMention(mention)
        //}
    }
    public func getNumberOfMentionsForTableView()->Int{
        return mentionsList().count
    }
    func getCellForMentions(_ tableView:UITableView,cellForRowAt indexPath: IndexPath)->UserMentionCellController{
        let cell = tableView.dequeueReusableCell(withIdentifier: "user",for:indexPath) as! UserMentionCellController
        
        cell.textLabel?.text = mentionsList()[indexPath.row].szMentionName
        
        if mentionsList()[indexPath.row].szMentionAvatar != ""{
            let _ = cell.setUserAvatar(mentionsList()[indexPath.row].szMentionAvatar)
        }
        return cell
    }
}

class UserMentionCellController: UITableViewCell,ImageServiceAsynchronouslyDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    var tableView:UITableView?
    func setUserAvatar(_ avatarUrl:String?)->Bool{
        //avatar.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        if avatarUrl != ""{
            ImageService.sharedInstance.getAsynchronously(avatar,url: avatarUrl!,newWidth:CGFloat(AppConstants.MOO_SOCIAL_IMAGE_CELL_WIDTH),callback: self)
            return true
        }
        return false
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        
       
    }
}

extension String {
    func image() -> UIImage {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.white.set()
        let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
        UIRectFill(CGRect(x: 0, y: 0, width: 30, height: 30))
        (self as NSString).draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

// MARK: Images Scroll
extension PostFeedController:UICollectionViewDelegate,UICollectionViewDataSource,TLPhotosPickerViewControllerDelegate{
    
    func initImageCollectView(){
        
        calculateImageCollectFrame()
        postImageScroll.delegate = self
        postImageScroll.dataSource = self
        postImageScroll.reloadData()
    }
    func calculateImageCollectFrame(){
        var y = WYMTextView.frame.origin.y + WYMTextView.frame.size.height
        if isFetchLinkShowed(){
            y += fetchLinkView.frame.height
        }
        postImageScroll.frame = CGRect(x:gPaddingLeft!,y:y,width:view.frame.size.width - 2*gPaddingLeft! ,height:125)
    }
    func loadPickImagesController(){
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 10
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
        // HACKING FOR MISSING PHOTO WHEN USING CAMERA
        initImageCollectView()
        if self.selectedAssets.count > 0{
            self.postButton.isEnabled = true
        }
        else if self.WYMTextView.text.isEmpty || self.WYMTextView.textColor == UIColor.lightGray{
            self.postButton.isEnabled = false
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
    func isShowImageCollectView()->Bool{
        return selectedAssets.count > 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAssets.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = postImageScroll.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostImageCollectionViewCell
        cell.imgImage.image = self.getAssetThumbnail(asset: self.selectedAssets[indexPath.row].phAsset!)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadPickImagesController()
    }
}
// MARK: Fetch-link View 
extension PostFeedController {
    
    func initFetchLinkView(){
        fetchLinkView.layer.borderWidth = 1
        fetchLinkView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PostFeedController.onTouchFetchLinkView(_:)))
        fetchLinkView.addGestureRecognizer(gesture)
        let _ = ActivityService.sharedInstance.registerCallback(self)
        
    }
    func isFetchLinkShowed()->Bool{
        return !fetchLinkView.isHidden
    }
    func showFetchLinkView(){
        fetchLinkView.isHidden = false
        postImageScroll.isHidden = true
        menuActionAdd.reloadData()
        initUITableView()
    }
    func hideFetchLinkView(){
        fetchLinkView.isHidden = true
        postImageScroll.isHidden = false
        menuActionAdd.reloadData()
        initUITableView()
    }
    func startLoadingFetchLink(){
    }
    func stopLoadingFetchLink(){
    }
    func fetchLinkCallback(_ data:AnyObject?){
        stopLoadingFetchLink()
        if let oURL = data as? [String:String]{
            if let title = oURL["title"]{
                self.titleFLView.text = title
            }
            if let image = oURL["image"]{
                ImageService.sharedInstance.getAsynchronously(self.imageFLView, url: image ,newWidth:CGFloat(),callback: self)
            }
            if let description = oURL["description"]{
                self.desFLView.text = description
            }
            self.fetchLink = oURL["url"]
            showFetchLinkView()
        }
        
    }
    func onTouchFetchLinkView(_ sender:UITapGestureRecognizer){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let removeButton = UIAlertAction(title: NSLocalizedString("post_feeds_remove_link",comment:"post_feeds_remove_link"), style: .default, handler: { (action) -> Void in
            self.hideFetchLinkView()
        })
        
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("post_feeds_cancel",comment:"post_feeds_cancel"), style: .cancel, handler: { (action) -> Void in
            
        })
        
        
        alertController.addAction(removeButton)
        
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
}


class PostImageCollectionViewCell:UICollectionViewCell{

    @IBOutlet weak var imgImage: UIImageView!

}
