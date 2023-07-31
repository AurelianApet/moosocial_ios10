//
//  WebViewController.swift
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

class MoreViewController: AppTableViewController {
    let _MYSECTION_ = 0
    let _MENUSECTION_ = 1
    let _PAGESECTION_ = 2
    let _WHATNEWTAB_ = 0
    let menu = AppConfigService.sharedInstance.appConfig["menus"] as! [String:Any]
    var meModel:UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.tableView.contentInset.top != 44.0 {
            self.tableView.contentInset = UIEdgeInsetsMake(44.0, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
        }
        
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
        switch section{
        case _MYSECTION_:
            return 1
        case _MENUSECTION_:
            if let items = menu["items"] as? [Any]{
                return items.count
            }
            //return (menu["items"] as! [Any]).count
        case _PAGESECTION_:
            if let pages = menu["pages"] as? [Any]{
                return pages.count
            }
            //return (menu["pages"]as! [Any]).count
        default :
            return 0
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = (indexPath as NSIndexPath).row
        if (indexPath as NSIndexPath).section == _MYSECTION_ {
            let cell1 = self.tableView.dequeueReusableCell(withIdentifier: "myMoreCell", for: indexPath) as! MyMoreCell
            self.meModel = UserService.sharedInstance.get()
            if self.meModel != nil && meModel?.avatar != nil{
                if let avatar  = meModel?.avatar as? [String:String]{
                    
                    if let url = avatar["100_square"] {
                        cell1.setItem(url, name: (meModel?.name)! as String)
                        
                        return cell1
                    }
                }
            }
        }else if (indexPath as NSIndexPath).section == _MENUSECTION_ {
                let cell2 = self.tableView.dequeueReusableCell(withIdentifier: "menuMoreCell", for: indexPath) as! MenuMoreCell
                self.meModel = UserService.sharedInstance.get()
                if self.meModel != nil{
                    if let items = menu["items"] as? [Any]{
                        if let item = items[row] as? [String:Any]{
                            cell2.setItem(item["icon"] as! String,menu:(item["label"] as? String)!)
                            return cell2
                        }
                    }
                
            }
        }else if (indexPath as NSIndexPath).section == _PAGESECTION_{
                    let cell3 = self.tableView.dequeueReusableCell(withIdentifier: "pageMoreCell", for: indexPath) as! PagesMoreCell
                    self.meModel = UserService.sharedInstance.get()
                    if self.meModel != nil{
                        if let pages = menu["pages"] as? [Any]{
                            if let item = pages[row] as? [String:Any]{
                                cell3.setItem((item["label"] as? String)!)
                                return cell3
                            }
                        }

                        
            }
        }
        let cell = UITableViewCell()

        return cell
    }
    override func numberOfSections(in tableView: UITableView?) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        headerView.backgroundColor = UIColor(colorLiteralRed: 243/255, green: 242/255, blue: 242/255, alpha: 1)
        // add border 230
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor(colorLiteralRed: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor

        border.frame = CGRect(x: 0, y: 0, width:  tableView.frame.size.width, height: 2)
        
        border.borderWidth = width
        headerView.layer.addSublayer(border)
        headerView.layer.masksToBounds = true
        
        let borderBottom = CALayer()
        borderBottom.borderColor = UIColor(colorLiteralRed: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        borderBottom.frame = CGRect(x: 0, y: 18, width:  tableView.frame.size.width, height: 2)
        
        borderBottom.borderWidth = width
        headerView.layer.addSublayer(borderBottom)
        
        
        return headerView
    }
    /*
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        footerView.backgroundColor = UIColor(colorLiteralRed: 243/255, green: 242/255, blue: 242/255, alpha: 1)
        // add border
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.blackColor().CGColor
        border.frame = CGRect(x: 0, y: 0, width:  tableView.frame.size.width, height: 1)
        
        border.borderWidth = width
        footerView.layer.addSublayer(border)
        footerView.layer.masksToBounds = true
        return UIView()

    }
    */
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == _MYSECTION_{
            return 65.0
        }
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var prepareForSegueURL = String()
        
        switch (indexPath as NSIndexPath).section{
        case _MYSECTION_:
            
            if let items = menu["items"] as? [Any]{
                if let value = items[(indexPath as NSIndexPath).row] as? [String:Any]{
                    self.meModel = UserService.sharedInstance.get()
                    prepareForSegueURL = (AppConfigService.sharedInstance.getBaseURL() as String) + (value["url"] as! String)
                   
                    let link = SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo(meModel!.profile_url!)
                    let url = URL(string:link)
                    self.parent?.performSegue( withIdentifier: "showWebBroswer", sender: url)
                }
            }
     
            break
        case _MENUSECTION_:
            if let items = menu["items"] as? [Any]{
                if let value = items[(indexPath as NSIndexPath).row] as? [String:Any]{
                    if(value["key"] as! String) == "external_link"{
                        prepareForSegueURL = value["url"] as! String
                    }else{
                        prepareForSegueURL = (AppConfigService.sharedInstance.getBaseURL() as String) + (value["url"] as! String)
                    }
                    goURL(prepareForSegueURL)
                }
            }
         
        case _PAGESECTION_:
            if let pages = menu["pages"] as? [Any]{
                if let value = pages[(indexPath as NSIndexPath).row] as? [String:Any]{

                    prepareForSegueURL = (AppConfigService.sharedInstance.getBaseURL() as String) + (value["url"] as! String)
                   
                    let url = URL(string:prepareForSegueURL)
                    self.parent?.performSegue( withIdentifier: "showCommentView", sender: url)
                }
            }
            
            break
        default :
            break
            
        }
        
    }
    func goURL( _ url:String,hasAccessToken:Bool=true){
        var url = url
        if hasAccessToken {
            url = addToken(url)
        }
        print("goURL:\(url)")
        url = addLanguage(url)

        
        self.parent?.performSegue( withIdentifier: "showWebBroswer", sender: URL(string:url))
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
}
class MyMoreCell: UITableViewCell,ImageServiceAsynchronouslyDelegate {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatarLoading: UIActivityIndicatorView!
    func setItem(_ avatarUrl:String, name:String){

         avatarLoading.startAnimating()
         ImageService.sharedInstance.getAsynchronously(avatar,url: avatarUrl,newWidth:CGFloat(),callback: self)
        self.name.text = name
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        avatarLoading.stopAnimating()
    }
}
class MenuMoreCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var menu: UILabel!
    func setItem(_ icon:String, menu:String){
        let icon_name = "more.icon." + icon
        
        if let image = UIImage(named:icon_name) {
            self.icon.image = image
        }
        // UIImage(named: "search.icon.user")
        //icon.image = ImageService.sharedInstance.get(avatarUrl,newWidth: 100)
        self.menu.text = NSLocalizedString(menu,comment:menu)
    }
}
class PagesMoreCell: UITableViewCell {

    @IBOutlet weak var page: UILabel!
    func setItem(_ page:String){
        
        self.page.text = NSLocalizedString(page,comment:page)
    }
}

