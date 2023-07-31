//
//  HomeViewController.swift
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

class MessagesViewController: AppTableViewController,AppServiceDelegate{
    var itemMessage:[MessageModel] = []
    var isLoading:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MessageService.sharedInstance.messageController = self
        MessageService.sharedInstance.registerCallback(self).show()
        NotificationService.sharedInstance.me()
        
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // Hacking for ios 8.1 8.2 8.3
        if self.tableView.contentInset.top != 64.0 {
            self.tableView.contentInset = UIEdgeInsetsMake(64.0, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEmptyMessages(){
            return 1
        }
        return itemMessage.count
    }
    func isEmptyMessages()-> Bool{
        return (itemMessage.count == 0)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEmptyMessages(){
            
            self.btViewMore.isHidden = true
            
            self.tableView.rowHeight = 40
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "emptyMessageCell", for: indexPath) as! MessagesTextCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            if isLoading{
                cell.message.text = NSLocalizedString("all_page_message_loading",comment:"all_page_message_loading")
            }else{
                cell.message.text = NSLocalizedString("messages_message_no_more_results_found",comment:"messages_message_no_more_results_found")
            }
            return cell
        }
        
        self.tableView.rowHeight = 80
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessagesCellController
        
        let row = (indexPath as NSIndexPath).row
        
        if row < itemMessage.count{
            let subject = itemMessage[row].subject
            let message = itemMessage[row].message
            
            
            //cell.imageView?.image?.size
            let object = itemMessage[row].object as! [String:Any]
            let subTitle = object["more_info"] as! String
            
            if let url = object["photo"]{
                _ = cell.setItem(url as! String,subject:subject!,message:message!,subTitle:subTitle)
            }
            
            /*
             if let object = itemMessage[row].valueForKey("object"){
             if let url = object["photo"]{
             let imgURL: NSURL = NSURL(string: url as! String)!
             let uiImage = UIImage(data:NSData(contentsOfURL: imgURL)!)
             if  uiImage != nil {
             cell.imageView!.image = uiImage
             let widthScale : CGFloat = 100 / cell.imageView!.image!.size.width
             let heightScale : CGFloat = 100 / cell.imageView!.image!.size.height;
             cell.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
             }
             }
             
             
             
             }
             */
            
            let unread = itemMessage[row].unread
            if unread {
                cell.backgroundColor = UIColor(red:0.9294,green:0.9373,blue:0.9608,alpha:1.0)
    
            }else{
                cell.backgroundColor = UIColor.white
            }
            
            
        }
        
        
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let id = self.itemMessage[indexPath.row].id {
            MessageService.sharedInstance.markAsRead(String(id),status:true)
            self.itemMessage[indexPath.row].unread = false
            tableView.reloadData()
        }

        if (!isEmptyMessages()){
            let url = URL(string:itemMessage[(indexPath as NSIndexPath).row ].link!)
            self.parent?.performSegue( withIdentifier: "showCommentView", sender: url)
        }
        
    }
    /*
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     if segue.identifier == "segueFromMessagesItemToHomePage" {
     
     let containerViewController = segue.destinationViewController as! ContainerViewController
     
     // Get the cell that generated this segue.
     if let selectedSearchCell = sender as? UITableViewCell {
     let indexPath = tableView.indexPathForCell(selectedSearchCell)!
     //let selectedUrl = itemSearchSuggestion[indexPath.row].url
     //homeTabBarViewController.actionParamater = selectedUrl
     containerViewController.centerViewAction =  AppConstants.ACTION_ACTIVE_WEB_ON_WHATS_NEW_FROM_OUTSIDE
     //WebViewService.sharedInstance.goURL(itemSearchSuggestion[indexPath.row].url!)
     
     WebViewService.sharedInstance.URLReload = itemMessage[indexPath.row].link!
     
     
     }
     }
     }
     */
    // Mark : AppServiceDeleage
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        
        switch identifier {
        case "MessageService.show.Success":
            
            isLoading = false
            if data == nil{
                self.itemMessage = []
            }
            
            if let items = data as? [MessageModel]{
                self.itemMessage = items
            }
            
            self.tableView.reloadData()
            
            // custom
            self.page = 1
            self.btViewMore.isHidden = false

        case "MessageService.before.showRequest":
            isLoading = true
            tableView.reloadData()
        default: break
        }
    }
    
    // custom view more
    @IBOutlet weak var btViewMore: UIButton!
    var page = 1;
    @IBAction func viewMoreAction(_ sender: Any) {
        self.page += 1;
        MessageService.sharedInstance.data(String(self.page))
        //self.btViewMore.isHidden = true
    }
}

class MessagesCellController: UITableViewCell,ImageServiceAsynchronouslyDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var avatarLoading: UIActivityIndicatorView!
    var isSetted = false
    func setItem(_ avatarUrl:String,subject:String,message:String,subTitle:String)->Bool{
        
        var subject = subject
        if subject.characters.count > 100 {
            if isSetted {
                //return true
            }
            
            //subject = subject.substringWithRange(Range<String.Index>(start: subject.startIndex, end: subject.startIndex.advancedBy(80))) + " ..."
            subject = subject.substring(with: subject.startIndex..<subject.characters.index(subject.startIndex, offsetBy: 80)) + " ..."
        }
        self.subject.text = subject
        self.message.text = message
        self.subTitle.text = subTitle
        avatarLoading.startAnimating()
        ImageService.sharedInstance.getAsynchronously(avatar,url: avatarUrl,newWidth:CGFloat(),callback: self)
        isSetted = true
        return true
        //avatar.image = ImageService.sharedInstance.get(avatarUrl,newWidth: 100)
        //ImageService.sharedInstance.getAsynchronously(avatar,url: avatarUrl,newWidth: 100)
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        avatarLoading.stopAnimating()
    }
}
class MessagesTextCellController:UITableViewCell{
    
    @IBOutlet weak var message: UILabel!
}
