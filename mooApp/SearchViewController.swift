//
//  SearchViewController.swift
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

class SearchViewController: AppTableViewController,UISearchBarDelegate, UISearchDisplayDelegate,AppServiceDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var itemSearchSuggestion:[SuggestSearchModel] = []
    var isLoading:Bool = false
    override func viewDidLoad() {
        navigationItem.titleView = searchBar
        navigationItem.hidesBackButton = true
        searchBar.delegate = self
        //SearchService.sharedInstance.searchController = self
        // Layout improvement 
        cancelButton.tintColor = AppConfigService.sharedInstance.config.color_title
    }
    /*
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
           }
    */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        if ValidateService.sharedInstance.isAllowKeyword(searchBar.text!){            
            SearchService.sharedInstance.registerCallback(self).suggest(searchBar.text!)
        }else{
           alert(ValidateService.sharedInstance.getLastMessage())
        }
    }
  
    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    func isEmptySuggestSearch()-> Bool{
        return (itemSearchSuggestion.count == 0)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEmptySuggestSearch(){
            return 1
        }
        return itemSearchSuggestion.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEmptySuggestSearch(){
            //self.tableView.rowHeight = 40
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "emptyMessageCell", for: indexPath) as! MessagesTextCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            if isLoading{
                cell.message.text = NSLocalizedString("all_page_message_loading",comment:"all_page_message_loading")
            }else{
                cell.message.text = ""
            }
            return cell
        }
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCellController
        let row = (indexPath as NSIndexPath).row
        
        if row < itemSearchSuggestion.count{
            
            _ = cell.setItem(itemSearchSuggestion[row].avatar!,title: itemSearchSuggestion[row].title_1!,subTitle: itemSearchSuggestion[row].title_2!,iconType: itemSearchSuggestion[row].type!)
            /*
            cell.textLabel?.text = itemSearchSuggestion[row].title_1
            cell.detailTextLabel?.text = itemSearchSuggestion[row].title_2
          
            cell.imageView?.image?.size

        
            
           
            let imgURL: NSURL = NSURL(string: itemSearchSuggestion[row].avatar!)!
                        cell.imageView!.image = UIImage(data:NSData(contentsOfURL: imgURL)!)
            let widthScale : CGFloat = 100 / cell.imageView!.image!.size.width
            let heightScale : CGFloat = 100 / cell.imageView!.image!.size.height;
            cell.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
            */
        }

        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        if (!isEmptySuggestSearch()){
            
            WebViewService.sharedInstance.goURL(itemSearchSuggestion[indexPath.row].url!)
            
            self.navigationController?.popViewControllerAnimated(true)
            
        }
        */
        if indexPath.row < itemSearchSuggestion.count{
            self.performSegue( withIdentifier: "showWebBrowser", sender: itemSearchSuggestion[indexPath.row].url)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebBrowser" {
            
            let containerViewController = segue.destination as! WebViewBrowserController
            
            // Get the cell that generated this segue.
            //if let selectedSearchCell = sender as? SearchCellController {
               // let indexPath = tableView.indexPath(for: selectedSearchCell)!
                
                //WebViewService.sharedInstance.URLReload = itemSearchSuggestion[indexPath.row].url!
                let link = SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo(sender as! String)
                let url = NSURL(string: link)! as URL
                containerViewController.url = url

           // }
        }
    }
    
    // Mark : AppServiceDeleage
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        
        switch identifier {
        case "SearchService.show.Success":
       
            isLoading = false
            if data == nil{
                self.itemSearchSuggestion = []
            }
            if let items = data as? [SuggestSearchModel]{
                self.itemSearchSuggestion = items
            }
      
            self.tableView.reloadData()
            
        case "SearchService.before.suggestRequest":
            isLoading = true
            tableView.reloadData()
        default: break
        }
    }

}

class SearchCellController: UITableViewCell,ImageServiceAsynchronouslyDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var icon: UIImageView!    
    @IBOutlet weak var avatarLoading: UIActivityIndicatorView!
    
     var isSetted = false
    func setItem(_ avatarUrl:String,title:String,subTitle:String,iconType:String)->Bool{

        self.title.text = title
        self.subTitle.text = subTitle

        //avatar.image = UIImage(data:NSData(contentsOfURL: imgURL)!)
        //avatar.image = ImageService.sharedInstance.get(avatarUrl,newWidth: 100)
        switch iconType{
        case "User":
            icon.image = UIImage(named: "search.icon.user")
            break
        case "Album":
            icon.image = UIImage(named: "search.icon.album")
            break
        case "Video":
            icon.image = UIImage(named: "search.icon.video")
            break
        case "Event":
            icon.image = UIImage(named: "search.icon.event")
            break
        case "Topic":
            icon.image = UIImage(named: "search.icon.topic")
            break
        case "Blog":
            icon.image = UIImage(named: "search.icon.blog")
            break
        case "Group":
            icon.image = UIImage(named: "search.icon.group")
            break
        default:
            break
        }

        //let widthScale : CGFloat = 100 / avatar.image!.size.width
        //let heightScale : CGFloat = 100 / avatar.image!.size.height;
        //self.avatar.transform = CGAffineTransformMakeScale(widthScale, heightScale)
        avatarLoading.startAnimating()
        ImageService.sharedInstance.getAsynchronously(avatar,url: avatarUrl,newWidth:CGFloat(),callback: self)
        isSetted = true
        return true
  
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        avatarLoading.stopAnimating()
    }
}
