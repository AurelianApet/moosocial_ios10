//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit


class MenuViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
     //Mark : Properties 
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameOwnerLabel: UILabel!
    @IBOutlet weak var mainMenuTableView: UITableView!
    let _WHATNEWTAB_ = 0
    let _MYSECTION_ = 0
    let _MENUSECTION_ = 1
    let _PAGESECTION_ = 2
    let textCellIdentifier = "TextCell"
    let menu = AppConfigService.sharedInstance.appConfig["menus"] as! [String:Any]
    var prepareForSegueURL:String?
    override func viewDidLoad() {
        mainMenuTableView.delegate = self
        mainMenuTableView.dataSource = self
       
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case _MYSECTION_:
            return 1
        case _MENUSECTION_:
            
            return (menu["items"] as! [Any]).count
        case _PAGESECTION_:
            return 3
        default :
            return 0
        }

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as UITableViewCell
        
        let row = (indexPath as NSIndexPath).row
        if let items = menu["items"] as? [Any]{
            if let rowRecord = items[row] as? [String:String]{
                cell.textLabel?.text = rowRecord["label"]
            }
        }

        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let items = menu["items"] as? [Any]{
            if let recordRow = items[(indexPath as NSIndexPath).row] as? [String:String]{
                prepareForSegueURL = (AppConfigService.sharedInstance.getBaseURL() as String) + recordRow["url"]!
                
                self.tabBarController!.selectedIndex = _WHATNEWTAB_
                if (indexPath as NSIndexPath).row == _WHATNEWTAB_ {
                    
                    WebViewService.sharedInstance.goHome()
                }
                else{
                    
                    self.tabBarController!.tabBar.tintColor = UIColor.gray
                    WebViewService.sharedInstance.goURL(prepareForSegueURL!)
                
                }
            }
            
        }
        
        
    }
   
}

