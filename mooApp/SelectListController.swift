//
//  SelectListController.swift
//  mooApp
//
//  Created by duy on 5/29/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import UIKit

// protocol used for sending data back
protocol SelectListDataDelegate: class {
    func getSelectedItems(selectedIds : [Int], selectedItems : [SelectListModel])
}

class SelectListController:UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userView: UITableView!
    
    var searchActive : Bool = false
    var isFriendsLoading=true
    var selectedIds : [Int] = []
    var selectedItems : [SelectListModel] = []
    var itemList : [SelectListModel] = []
    var searchText : String = ""
    weak var delegate: SelectListDataDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /* Setup delegates */
        userView.delegate = self
        userView.dataSource = self
        searchBar.delegate = self
        
         //FriendService.sharedInstance.registerCallback(self)
    }
    
    func setItemList(itemList: [SelectListModel]){
        self.itemList = itemList
    }
    
    //pass selected items to previous view
    override func viewWillDisappear(_ animated: Bool) {
        // call this method on whichever class implements our delegate protocol
        self.selectedItems = self.getSelectedItems()
        delegate?.getSelectedItems(selectedIds: self.selectedIds, selectedItems: self.selectedItems)
    }
    
    func getSelectedItems() -> [SelectListModel]{
        var list : [SelectListModel] = []
        if self.selectedIds.count > 0{
            for user in self.itemList{
                if self.selectedIds.contains(user.id){
                    list.append(user)
                }
            }
        }
        return list
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(self.itemList.count == 0){
            searchActive = false;
        } else {
            self.searchText = searchText
            searchActive = true;
        }
        self.userView.reloadData()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return self.searchItem()!.count
        }
        
        return self.itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as! SelectListCellController
        var item : SelectListModel?
        if(searchActive){
            item = self.searchItem()?[indexPath.row]
        } else {
            item = self.itemList[indexPath.row]
        }
        
        cell.textLabel?.text = item?.name
        if (self.selectedIds.contains((item?.id)!)){
            cell.detailTextLabel?.text = "✓"
        }else{
            cell.detailTextLabel?.text = ""
        }
        let _ = cell.setUserAvatar(item?.avatar)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item : SelectListModel?
        if(searchActive){
            item = self.searchItem()?[indexPath.row]
        } else {
            item = self.itemList[indexPath.row]
        }
        if let uId = item?.id {
            if (self.selectedIds.contains(uId)){
                self.selectedIds = (self.selectedIds.filter(){$0 != uId})
            }else{
                self.selectedIds.append((item?.id)!)
            }
        }
        tableView.reloadData()
    }

}
// Mark : Avatar button , usernmae
extension SelectListController:AppServiceDelegate,ImageServiceAsynchronouslyDelegate{
    
    
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        switch identifier {
        case "FriendService.get.Success":
            isFriendsLoading = false
            userView.reloadData()
        case "FriendService.before.get":
            isFriendsLoading = true
        default: break
        }
    }
    func doAfterGetAsynchronously(_ img:UIImage?){
        //avatar.setImage(img,for: UIControlState())
    }
    
    func searchItem(_ refesh:Bool = false)->[SelectListModel]?{
        /*if refesh{
            getRaw()
            return [SelectListModel]()
        }else{
            if mentions.isEmpty{
                getRaw()
                return [SelectListModel]()
            }
        }*/
        if self.searchText != "" {
            return (itemList.filter({ (user) -> Bool in
                let tmp: NSString = (user as SelectListModel).name as NSString
                let range = tmp.range(of: self.searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            }))
        }
        return itemList
    }
}

class SelectListCellController:UITableViewCell,ImageServiceAsynchronouslyDelegate{
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
