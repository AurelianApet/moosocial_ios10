//
//  GroupService.swift
//  mooApp
//
//  Created by duy on 5/5/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import Alamofire
open class GroupService : AppService {
    // Mark: Properties
    var groups:[GroupModel] = []
    var messageController: MessagesViewController?
    private var szgroup=[SZGroup]()

    // Mark: init
    override init() {
        super.init()
    }
    
    // Mark: Singleton
    class var sharedInstance : GroupService {
        struct Singleton {
            static let instance = GroupService()
        }
        
        // Return singleton instance
        return Singleton.instance
    }
    
    func getGroups(_ filter:String = "",_ refesh:Bool = false)->[SZGroup]?{
        
        if refesh{
            getRaw()
            return [SZGroup]()
        }else{
            if szgroup.isEmpty{
                getRaw()
                return [SZGroup]()
            }
        }
        if filter != "" {
            return (szgroup.filter({ (user) -> Bool in
                let tmp: NSString = (user as SZGroup).szMentionName as NSString
                let range = tmp.range(of: filter, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            }))
        }
        return szgroup
    }
    
    // Mark: process
    /*
     * Get all notifcation of user
     */
    func getRaw(){
        AlamofireService.sharedInstance.privateSession!.request(api!["URL_MY_GROUP_LIST","hasToken"], method: .get,encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    if let json = JSON as? [String : Any] {
                        self.groups = []
                        self.szgroup = [SZGroup]()
                        if let data = json["groups"] as? [Any] {
                            for case let  item as [String:Any] in data {
                                let group = GroupModel(json:item)
                                let szgroup = SZGroup()
                                self.groups.append(group!)
                                szgroup.szMentionName = (group?.name!)!
                                szgroup.szMentionId = (group?.id)!
                                if let photo = group?.photo?["200_square"] {
                                    szgroup.szMentionAvatar = photo
                                }
                                else{
                                    szgroup.szMentionAvatar = (group?.image)!
                                }
                                self.szgroup.append(szgroup)
                            }
                        }
                        self.dispatch("GroupService.get.Success",data: self.groups as AnyObject?)
                    }else{
                        if let _ = JSON as? [String:String]{
                            self.dispatch("GroupService.get.Success",data: nil)
                        }else{
                            print("Something wrong - json must be NSARRAY for requrest " + self.api!["URL_LIST_MESSEAGE","hasToken"])
                        }
                    }
                    break
                    
                case .failure(let error):
                    if let statusCode = response.response?.statusCode  {
                        if statusCode == 404 {
                            self.dispatch("GroupService.get.Success",data: nil)
                            
                        }else{
                            if let data = response.data {
                                
                                if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                                    AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                                    print("\(error)")
                                }
                                print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                                
                            }
                        }
                    }
                    
                }
        }
        
    }
}

class SZGroup: SZCreateMentionProtocol {
    var szMentionId:Int = 0
    var szMentionName: String = ""
    var szMentionAvatar:String = ""
    var szMentionRange: NSRange = NSMakeRange(0, 0)
}
