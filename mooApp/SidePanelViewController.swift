//
//  SidePanelViewController.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit


protocol SidePanelViewControllerDelegate {
//    func animalSelected(animal: Animal)
    func menuSelected(_ key:String,url:String)
}

class SidePanelViewController: UIViewController {
    let _MySection_ = 0
    let _MenuSection_ = 1
    var meModel:UserModel?
    @IBOutlet weak var tableView: UITableView!
    var delegateEx: SidePanelViewControllerDelegate?
    let menu = AppConfigService.sharedInstance.appConfig["menus"] as! [String:Any]
//    var animals: Array<Animal>!
    
    struct TableView {
        struct CellIdentifiers {
            static let MenuCell = "RightMenuCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.reloadData()
    }
    
}

// MARK: Table View Data Source

extension SidePanelViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == _MySection_{
            return NSLocalizedString("menus_account_profile_menu",comment:"menus_account_profile_menu");
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == _MySection_ {
            return 1
        }
        if section == _MenuSection_ {
            if let account = menu["account"] as? [Any]{ 
                return account.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        


        let row = (indexPath as NSIndexPath).row
        
        if (indexPath as NSIndexPath).section == _MySection_ {
                    let cell1 = self.tableView.dequeueReusableCell(withIdentifier: "RightProfileCell", for: indexPath) as! RightProfileCell
                    self.meModel = UserService.sharedInstance.get()
            if self.meModel != nil{
                if let avatar  = meModel?.avatar as? [String:String]{
                    
                    if let url = avatar["100_square"] {
                        cell1.setItem(url, name: (meModel?.name)! as String)
                    }
                }
                
                 cell1.separatorInset =  UIEdgeInsetsMake(0, cell1.bounds.size.width, 0, 0);
                return cell1
            }
            
        }else if (indexPath as NSIndexPath).section == _MenuSection_ {
            
                    let cell2 = self.tableView.dequeueReusableCell(withIdentifier: "RightMenuCell", for: indexPath) as! RightMenuCell
                    if let account = menu["account"] as? [Any]{
                        if let item = account[row] as? [String:Any]{
                            cell2.setItem(item["label"] as! String)
                            return cell2
                        }
                    }
            
                   // cell2.textLabel?.text = menu!["account"]!![row]["label"] as? String
            
                           }
        let cell = self.tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.MenuCell, for: indexPath) as! RightMenuCell
        return cell

    }
    
}

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == _MySection_{
            let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            header.contentView.backgroundColor = UIColor(red: 40/255, green: 39/255, blue: 40/255, alpha: 1.0)
            header.textLabel!.textColor = UIColor.white //make the text white
            header.alpha = 0.5
            header.textLabel!.font = header.textLabel!.font.withSize(12)
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == _MySection_ {
            self.meModel = UserService.sharedInstance.get()
            if self.meModel != nil &&  meModel!.profile_url != nil {
                let profile_url = WebViewService.sharedInstance.addToken(meModel!.profile_url!)
                delegateEx?.menuSelected("profile_detail", url: profile_url)
            }
        }else if (indexPath as NSIndexPath).section == _MenuSection_ {
            if let account = menu["account"] as? [Any]{
                if let val = account[(indexPath as NSIndexPath).row] as? [String:Any]{
                    let key = val["key"] as! String
                    switch key {
                    case "account_logout":
                        doLogout()
                    case "account_picture":
                        delegateEx?.menuSelected(key, url: "")
                    default:
                        //let titleLocalized = NSLocalizedString(menu!["account"]!![indexPath.row]["label"] as! String,comment:menu!["account"]!![indexPath.row]["label"] as! String)
                        //AppHelperService.sharedInstance.setTitle(titleLocalized)
                        //AppHelperService.sharedInstance.setWhatNewFilter(nil)
                        let prepareForSegueURL = (AppConfigService.sharedInstance.getBaseURL() as String) + (val["url"] as! String)
                        //WebViewService.sharedInstance.goURL(prepareForSegueURL)
                        delegateEx?.menuSelected(key, url: prepareForSegueURL)
                    }
                }
            }
            
        }
        
        
        /*
        if (menu!["account"]!![indexPath.row]["key"] as! String ) == "account_logout"{
            
            doLogout()
        }else{
            let prepareForSegueURL = (AppConfigService.sharedInstance.getBaseURL() as String) + (menu!["account"]!![indexPath.row]["url"] as! String)
            WebViewService.sharedInstance.goURL(prepareForSegueURL)
            delegate?.menuSelected()
        }
        */
    }
    func doLogout(){
        AuthenticationService.sharedInstance.doLogout()
        
        //get setting
        AuthenticationService.sharedInstance.settings()
        
        self.performSegue(withIdentifier: "segueForLogoutToShowLogin", sender: self)
    }
}


class RightProfileCell: UITableViewCell,ImageServiceAsynchronouslyDelegate {
    
 
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatarLoading: UIActivityIndicatorView!
    
    func setItem(_ avatarUrl:String, name:String){
        avatar.layer.borderWidth = 0.7
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.clipsToBounds = true

        ImageService.sharedInstance.getAsynchronously(avatar,url: avatarUrl,newWidth:CGFloat(),callback: self)
        
        self.name.text = NSLocalizedString(name,comment:name)
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        avatarLoading.stopAnimating()
    }
}
class RightMenuCell: UITableViewCell {
    
    @IBOutlet weak var menu: UILabel!
    func setItem(_ menu:String){
        self.menu.text = NSLocalizedString(menu,comment:menu)
    }
}



