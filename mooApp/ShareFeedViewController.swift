//
//  ShareFeedViewController.swift
//  mooApp
//
//  Created by tuan on 6/14/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import UIKit
import TLPhotoPicker
import Photos

class ShareFeedViewController: UIViewController, SelectListDataDelegate, ShareInputDataDelegate {

    @IBOutlet var menuAddToYourPost: UITableView!
    
    @IBOutlet weak var menuActionAdd: UITableView!
    @IBOutlet weak var WYMTextView: UITextView!
    
    //@IBOutlet weak var postImageScroll: UICollectionView!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var selectItemTextView: UITextView!
    @IBOutlet weak var selectItemLabel: UILabel!
    
    //@IBOutlet weak var optPrivacy: UIButton!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    
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
    var userTagging:[Int] = []
    var selectedFriends : [Int] = []
    var selectedGroups : [Int] = []
    var userTaggingList:[SelectListModel] = []
    var selectedFriendList : [SelectListModel] = []
    var selectedGroupList : [SelectListModel] = []
    var emailText : String = ""
    var selectListOption : Int = 0
    var shareFeedType : String = AppConstants.SHARE_FEED_TYPE_NORMAL
    var shareObjectId : Int = 0
    var shareAction : String = "wall_post_share"
    var shareItemType : String = ""
    var shareParam : String = ""
    var webData:[String:Any]? // used when is called by share event from whatnewWK
    
    override func viewDidLoad() {
        // Suppports NSLocalizedString
        navigationItem.title = NSLocalizedString("post_feeds_page_title",comment:"post_feeds_page_title")
        
        // End supports NSLocalizedString
        self.navigationController?.navigationBar.tintColor = AppConfigService.sharedInstance.config.color_title
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = false
        
        //set data from webview
        if webData != nil{
            if let object = webData?["objects"] as? [String:Any]{
                if (object["share_type"] as? String) != nil {
                    self.shareFeedType = (object["share_type"] as? String)!
                }
                if (object["id"] as? String) != nil {
                    self.shareObjectId = Int((object["id"] as? String)!)!
                }
                if (object["action"] as? String) != nil {
                    self.shareAction = (object["action"] as? String)!
                }
                if (object["item_type"] as? String) != nil {
                    self.shareItemType = (object["item_type"] as? String)!
                }
                if (object["param"] as? String) != nil {
                    self.shareParam = (object["param"] as? String)!
                }
            }
            
        }
        
        initUITableView()
        initTextView()
        updateAvatarAndName()
    }
    
    //get user tagging from delegate
    func getSelectedItems(selectedIds: [Int], selectedItems: [SelectListModel]) {
        switch self.selectListOption {
        case 1:
            self.userTagging = selectedIds
            self.userTaggingList = selectedItems
        case 2:
            self.selectedFriends = selectedIds
            self.selectedFriendList = selectedItems
        case 3:
            self.selectedGroups = selectedIds
            self.selectedGroupList = selectedItems
        default: break
            
        }
        
    }
    
    @IBAction func onCancel(_ sender: Any) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onPost(_ sender: Any) {
        
        //validate
        if self.shareFeedType == AppConstants.SHARE_FEED_TYPE_FRIEND && self.selectedFriends.count == 0{
            AlertService.sharedInstance.process(NSLocalizedString("share_page_alert_select_friends_to_share",comment:"share_page_alert_select_friends_to_share"))
        }
        else if self.shareFeedType == AppConstants.SHARE_FEED_TYPE_GROUP && self.selectedGroups.count == 0{
            AlertService.sharedInstance.process(NSLocalizedString("share_page_alert_select_groups_to_share",comment:"share_page_alert_select_groups_to_share"))
        }
        else if self.shareFeedType == AppConstants.SHARE_FEED_TYPE_EMAIL && self.selectItemTextView.text == ""{
            AlertService.sharedInstance.process(NSLocalizedString("share_page_alert_input_email_to_share",comment:"share_page_alert_input_email_to_share"))
        }
        else{
            //validate email
            var isValidEmail : Bool = true
            if self.shareFeedType == AppConstants.SHARE_FEED_TYPE_EMAIL{
                let emails : [String] = self.selectItemTextView.text.characters.split(separator: ",").map(String.init)
                if emails.count > 0{
                    for email in emails{
                        if !ValidateService.sharedInstance.isEmail(email){
                            isValidEmail = false
                            break
                        }
                    }
                }
            }
            
            if !isValidEmail{
                AlertService.sharedInstance.process(NSLocalizedString("all_page_message_invalid_email",comment:"all_page_message_invalid_email"))
            }
            else{
                let shareService = ShareService()
                shareService.setData(share_type: self.shareFeedType, object_id: self.shareObjectId, action: self.shareAction, item_type: self.shareItemType, param: self.shareParam)
                shareService.userTaging = self.userTagging
                shareService.WhatsNewWKController = self.WhatsNewController
                shareService.message = (mentionsListener?.getTextWithMentionFormat())!
                shareService.messageText = WYMTextView.text
                
                switch self.shareFeedType {
                case AppConstants.SHARE_FEED_TYPE_FRIEND:
                    shareService.friendSuggestion = self.selectedFriends
                case AppConstants.SHARE_FEED_TYPE_GROUP:
                    shareService.groupSuggestion = self.selectedGroups
                case AppConstants.SHARE_FEED_TYPE_EMAIL:
                    shareService.email = self.selectItemTextView.text
                default:
                    break
                }
                shareService.post()
                navigationController!.popViewController(animated: true)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        self.showUserTagged()
        self.showSelectItems()
        GroupService.sharedInstance.getGroups()!
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
        if segue.identifier == "ShareSelectListSegue" {
            let destinationController = segue.destination as! SelectListController
            
            //load user list
            var itemList : [SelectListModel] = []
            if self.selectListOption == 1 || self.selectListOption == 2{ //select user tag or select friends
                let users:[SZUserMention] = FriendService.sharedInstance.getMentions()!
                if users.count > 0{
                    for user in users{
                        let item = SelectListModel()
                        item.setData(id : user.szMentionId, avatar: user.szMentionAvatar, name: user.szMentionName)
                        itemList.append(item)
                    }
                }
            }
            else if self.selectListOption == 3{ //select group
                let groups:[SZGroup] = GroupService.sharedInstance.getGroups()!
                if groups.count > 0{
                    for group in groups{
                        let item = SelectListModel()
                        item.setData(id : group.szMentionId, avatar: group.szMentionAvatar, name: group.szMentionName)
                        itemList.append(item)
                    }
                }
            }
            
            //prepare data for select list view
            destinationController.setItemList(itemList : itemList)
            
            //set selected items
            switch self.selectListOption {
            case 1:
                destinationController.selectedIds = self.userTagging
            case 2:
                destinationController.selectedIds = self.selectedFriends
            case 3:
                destinationController.selectedIds = self.selectedGroups
            default: break
                
            }
            
            destinationController.delegate = self
        }
        else if segue.identifier == "ShowShareInputSegue" {
            let destinationController = segue.destination as! ShareInputViewController
            destinationController.emailText = self.emailText
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
extension ShareFeedViewController:UITextViewDelegate{
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
        // WYMTextView.frame = CGRect(x:avatar.frame.origin.x,y:128,width:view.frame.size.width - 20,height:125)
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
        return 1
    }
    func getCellForMenuActionAdd(_ tableView:UITableView,cellForRowAt indexPath: IndexPath)->UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("post_feeds_tag_friends",comment:"post_feeds_tag_friends")
            cell.imageView?.image = "👤".image()
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
extension ShareFeedViewController:UITableViewDelegate,UITableViewDataSource{
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
        menuActionAdd.frame = CGRect(x:view.frame.origin.x,y:view.frame.size.height - 45,width:view.frame.size.width,height:45)
        
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
                self.selectListOption = 1
                self.performSegue( withIdentifier: "ShareSelectListSegue", sender: self)
            case 1:
                self.selectListOption = 2
                self.performSegue( withIdentifier: "ShareSelectListSegue", sender: self)
            case 2:
                self.selectListOption = 3
                self.performSegue( withIdentifier: "ShareSelectListSegue", sender: self)
            /*case 1:
                loadPickImagesController()*/
                
            default:
                break
            }
        }
        
    }
}
// MARK: Avatar button , usernmae
extension ShareFeedViewController:AppServiceDelegate,ImageServiceAsynchronouslyDelegate{
    
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
        case "GroupService.get.Success":
            isFriendsLoading = false
            menuAddToYourPost.reloadData()
        case "GroupService.before.get":
            isFriendsLoading = true
        default: break
        }
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        //avatar.setImage(img,for: UIControlState())
    }
}
// MARK: Mention
extension ShareFeedViewController:SZMentionsManagerProtocol{
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
        //optPrivacy.isHidden = status
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

// MARK: select friends
extension ShareFeedViewController{
    func showSelectItems(){
        if self.shareFeedType == AppConstants.SHARE_FEED_TYPE_NORMAL{ //normal share
            self.selectItemLabel.isHidden = true
            self.selectItemTextView.isHidden = true
        }
        else{ //share with select special items - friends, group, email
            
            self.selectItemTextView.textColor = UIColor.lightGray
            
            switch self.shareFeedType {
            case AppConstants.SHARE_FEED_TYPE_FRIEND: //friend type
                //set text
                self.selectItemLabel.text = NSLocalizedString("post_feeds_select_friend",comment:"post_feeds_select_friend")
                self.selectItemTextView.text = NSLocalizedString("post_feeds_select_friend_placeholder",comment:"post_feeds_select_friend_placeholder")
                
                //show friends
                if self.selectedFriendList.count > 0{
                    var friends : [String] = []
                    for user : SelectListModel in self.selectedFriendList{
                        friends.append(user.name)
                    }
                    self.selectItemTextView.text = friends.joined(separator: ", ")
                    self.selectItemTextView.textColor = AppConfigService.sharedInstance.config.navigationBar_barTintColor
                }

            case AppConstants.SHARE_FEED_TYPE_GROUP: //group type
                //set text
                self.selectItemLabel.text = NSLocalizedString("post_feeds_select_group",comment:"post_feeds_select_group")
                self.selectItemTextView.text = NSLocalizedString("post_feeds_select_group_placeholder",comment:"post_feeds_select_group_placeholder")
                
                //show groups
                if self.selectedGroupList.count > 0{
                    var friends : [String] = []
                    for user : SelectListModel in self.selectedGroupList{
                        friends.append(user.name)
                    }
                    self.selectItemTextView.text = friends.joined(separator: ", ")
                    self.selectItemTextView.textColor = AppConfigService.sharedInstance.config.navigationBar_barTintColor
                }
                
            case AppConstants.SHARE_FEED_TYPE_EMAIL: //email type
                self.selectItemLabel.text = NSLocalizedString("post_feeds_select_email",comment:"post_feeds_select_email")
                self.selectItemTextView.text = NSLocalizedString("post_feeds_select_email_placeholder",comment:"post_feeds_select_email_placeholder")
                
                //show email
                if self.emailText != ""{
                    self.selectItemTextView.text = self.emailText;
                    self.selectItemTextView.textColor = AppConfigService.sharedInstance.config.navigationBar_barTintColor
                }
            default:
                break
            }
            
            //set click to open select friend popup
            let tapOutTextField: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ShareFeedViewController.selectItemClick))
            self.selectItemTextView.addGestureRecognizer(tapOutTextField)
        }
    }
    
    //open select list popup for friends
    func selectItemClick(){
        switch self.shareFeedType {
        case AppConstants.SHARE_FEED_TYPE_FRIEND:
            self.selectListOption = 2
            self.performSegue( withIdentifier: "ShareSelectListSegue", sender: self)
        case AppConstants.SHARE_FEED_TYPE_GROUP:
            self.selectListOption = 3
            self.performSegue( withIdentifier: "ShareSelectListSegue", sender: self)
        case AppConstants.SHARE_FEED_TYPE_EMAIL:
            self.performSegue( withIdentifier: "ShowShareInputSegue", sender: self)
        default:
            break
        }
    }
    
    //get email text from ShareInputViewController
    func getText(text : String){
        self.emailText = text
    }
}
