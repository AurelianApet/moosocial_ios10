//
//  SecondViewController.swift
//  TabBar
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit

class NotificationsViewController: AppTableViewController,AppServiceDelegate {
    var itemNotification:[NotificationModel] = []
    let CELL_ITEM_TYPE = 0
    let CELL_ACTIONS_TYPE = 1
  
    var isLoading:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationService.sharedInstance.notificationController = self
        NotificationService.sharedInstance.registerCallback(self).show()
        //self.page += 1
        //NotificationService.sharedInstance.data(String(self.page))
        NotificationService.sharedInstance.me() // Not need registerCallack
        UserService.sharedInstance.me()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // Hacking for ios 8.1 8.2 8.3
        
        if self.tableView.contentInset.top != 64.0 {
            self.tableView.contentInset = UIEdgeInsetsMake(64.0, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEmptyNotifications(){
            return 1
        }
        if isNeedAddCellActions() {
            return itemNotification.count + 1
        }
        return itemNotification.count
    }
    // Swipe to delete 
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let row = (indexPath as NSIndexPath).row - 1
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: NSLocalizedString("notifications_page_buton_delete",comment:"notifications_page_buton_delete") , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            
            
            if let id = self.itemNotification[indexPath.row-1].id{
                    NotificationService.sharedInstance.remove(id)
                    self.itemNotification.remove(at: indexPath.row-1)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        })
        let readAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: NSLocalizedString("notifications_page_buton_read",comment:"notifications_page_buton_read") , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            if let id = self.itemNotification[indexPath.row-1].id {
                
                NotificationService.sharedInstance.markAsRead(id,status:true)
                self.itemNotification[indexPath.row-1].unread = false
                tableView.reloadData()
            }
            

            
        })
       
        let unreadAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: NSLocalizedString("notifications_page_buton_unread",comment:"notifications_page_buton_unread") , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            if let id = self.itemNotification[indexPath.row-1].id {
                
                NotificationService.sharedInstance.markAsRead(id,status:false)
                self.itemNotification[indexPath.row-1].unread = true
                tableView.reloadData()
            }

        })
        readAction.backgroundColor = UIColor.blue
        unreadAction.backgroundColor = UIColor.blue
       
            if itemNotification[row].unread {
                return [deleteAction,readAction]
            }else{
                return [deleteAction,unreadAction]
            }
    }
    /*
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            if let id = itemNotification[indexPath.row-1].valueForKey("id") as? String {
                
                NotificationService.sharedInstance.remove(id)
            }
            itemNotification.removeAtIndex(indexPath.row-1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
          
            
            
        }
    }
    */
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       
        return !((indexPath as NSIndexPath).row == 0)
    }
    
    func isNeedAddCellActions()-> Bool{
        return (itemNotification.count > 0)
    }
    func isEmptyNotifications()->Bool{
        return (itemNotification.count == 0)
    }
    
    func createCellItem(_ tableView: UITableView,cellForRowAtIndexPath indexPath: IndexPath)->NotificationsCellController{
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationsCellController
        let row = (indexPath as NSIndexPath).row - 1
        self.tableView.rowHeight = 75
        
        if row < itemNotification.count{
        var objectTitle = "" as String
        if let from = itemNotification[row].from as? NSDictionary{
            if (from["name"] as? String) != nil{
                objectTitle = from["name"] as! String
            }
            
        }
        var title = "" as String
        title += " " + itemNotification[row].title!
        if let to = itemNotification[row].to as? NSDictionary{
            title += " " + (to["name"] as! String)
        }
            
        let object = itemNotification[row].object as? NSDictionary
        let subTitle = itemNotification[row].created_time
        if let url = object!["photo"]{
            if(url as? String) != nil {
                if cell.setItem(url as? String,object:objectTitle, title: title, subTitle:subTitle!){
                 
                }
            }
            
        }
        let unread = itemNotification[row].unread
        
        if unread {
            cell.backgroundColor = UIColor(red:0.9294,green:0.9373,blue:0.9608,alpha:1.0)
        }else{
            cell.backgroundColor = UIColor.white
        }
        }
        
        return cell
    }
    func createCellActions(_ tableView: UITableView,cellForRowAtIndexPath indexPath: IndexPath)->NotificationsActionsCellController{
        self.tableView.rowHeight = 40
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath) as! NotificationsActionsCellController
        cell.initStyle()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = UIColor(red:0.9294,green:0.9373,blue:0.9608,alpha:1.0)
        return cell
    }
    func createEmptyMessageCell(_ tableView: UITableView,cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{

        let cell =  self.tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! NotificationsMessageCellController
        self.tableView.rowHeight = 40
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if isLoading{
            cell.message.text = NSLocalizedString("all_page_message_loading",comment:"all_page_message_loading")
        }else{
            cell.message.text = NSLocalizedString("notifications_page_mesage_no_new_notifications",comment:"notifications_page_mesage_no_new_notifications")
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = (indexPath as NSIndexPath).row
        if isEmptyNotifications(){
            self.btViewMore.isHidden = true
            return createEmptyMessageCell(tableView, cellForRowAtIndexPath: indexPath)
        }
        if row == 0{
           
            return createCellActions(tableView, cellForRowAtIndexPath: indexPath)
        }else{
            
            return createCellItem(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let id = self.itemNotification[indexPath.row-1].id {
            
            NotificationService.sharedInstance.markAsRead(id,status:true)
            self.itemNotification[indexPath.row-1].unread = false
            tableView.reloadData()
        }
        if !isEmptyNotifications() && (indexPath as NSIndexPath).row > 0 {
            let link = SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo(itemNotification[(indexPath as NSIndexPath).row - 1].link!)
            let url = NSURL(string: link)! as URL
            self.parent?.performSegue( withIdentifier: "showWebBroswer", sender: url)
        }
 
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromNotificationsItemToHomePage" {
            
            let containerViewController = segue.destination as! ContainerViewController
            
            // Get the cell that generated this segue.
            if let selectedSearchCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: selectedSearchCell)!
                //let selectedUrl = itemSearchSuggestion[indexPath.row].url
                //homeTabBarViewController.actionParamater = selectedUrl
                containerViewController.centerViewAction =  AppConstants.ACTION_ACTIVE_WEB_ON_WHATS_NEW_FROM_OUTSIDE
                //WebViewService.sharedInstance.goURL(itemSearchSuggestion[indexPath.row].url!)
                WebViewService.sharedInstance.URLReload = itemNotification[(indexPath as NSIndexPath).row - 1].link!

                
            }
        }
    }
    // Mark : AppServiceDeleage
    func serviceCallack(_ identifier: String, data: AnyObject?) {

        switch identifier {
        case "NotificationService.show.Success":
         
            isLoading = false
            if data == nil{
                self.itemNotification = []
            }
            if let items = data as? [NotificationModel]{
                self.itemNotification = items
            }

            self.tableView.reloadData()
            
            // custom
            self.page = 1
            self.btViewMore.isHidden = false

        case "NotificationService.before.showRequest":
            isLoading = true
            tableView.reloadData()
        default: break
        }
    }
    
    // cus view more
    var page = 1
    @IBOutlet weak var btViewMore: UIButton!
    @IBAction func viewMoreAction(_ sender: Any) {
        self.page += 1
        NotificationService.sharedInstance.data(String(self.page))
    }
    
}

class NotificationsCellController: UITableViewCell,ImageServiceAsynchronouslyDelegate {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var object: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var isSetted = false
    var myMutableString = NSMutableAttributedString()
    func setItem(_ avatarUrl:String?,object:String,title:String,subTitle:String)->Bool{
        var object = object
        if isSetted {
            //return true
        }
        
        //self.title.text = title
        if object.characters.count > 40 {
            //object.substringWithRange(Range<String.Index>(start: 0, end: 10))
            
            object = object.substring(with: Range<String.Index>( object.startIndex ..< object.characters.index(object.startIndex, offsetBy: 20))) + " ..."
        }
        self.object.text = object + " " + title
        myMutableString = NSMutableAttributedString(
            string: object + " " + title,
            attributes: [NSFontAttributeName:
                UIFont.systemFont(ofSize: 13)])
        myMutableString.addAttribute(NSFontAttributeName,
            value: UIFont.boldSystemFont(ofSize: 13),
            range: NSRange(
                location: 0,
                length: object.characters.count))
        self.object.attributedText = myMutableString
        self.subTitle.text = subTitle

        //avatar.image = ImageService.sharedInstance.get(avatarUrl,newWidth: 100)
        loading.startAnimating()
        ImageService.sharedInstance.getAsynchronously(avatar,url: avatarUrl!,newWidth:CGFloat(),callback: self)
        isSetted = true
        return true
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        loading.stopAnimating()
    }
}

class NotificationsActionsCellController: UITableViewCell{

    @IBOutlet weak var clearActionsButton: UIButton!
    
    @IBAction func clearAllNotifications(_ sender: AnyObject) {
        
        NotificationService.sharedInstance.clear()
    }


    
    
    func initStyle(){
        clearActionsButton.setTitle(NSLocalizedString("notifications_page_buton_clear_all_notifications",comment:"notifications_page_buton_clear_all_notifications"), for: UIControlState())
        //clearActionsButton.layer.cornerRadius = 3;
        //clearActionsButton.layer.borderWidth = 0;
        
        //clearActionsButton.layer.borderColor = AppConfigService.sharedInstance.config.color_button_action_background.CGColor
        //clearActionsButton.layer.backgroundColor = AppConfigService.sharedInstance.config.color_button_action_background.CGColor


    }
}
class NotificationsMessageCellController: UITableViewCell{

    @IBOutlet weak var message: UILabel!
   
}
