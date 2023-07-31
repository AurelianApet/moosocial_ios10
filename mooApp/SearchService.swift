//
//  SearchService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit
import Alamofire
open class SearchService : AppService {
    // Mark: Properties
    var itemSearchSuggestion:[SuggestSearchModel] = []
    var searchController:SearchViewController?
    // Mark: init
    override init() {
        super.init()
    }
    // Mark: Singleton
    class var sharedInstance : SearchService {
        struct Singleton {
            static let instance = SearchService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    // Mark: process
    func suggest(_ keyword:String){
        
        if ValidateService.sharedInstance.isAllowKeyword(keyword){

            
            self.dispatch("SearchService.before.suggestRequest")
            AlamofireService.sharedInstance.privateSession!.request( api!["URL_SEARCH","hasToken"],method:.post,parameters: ["keyword":keyword],encoding: JSONEncoding.default )
                    .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let JSON):
                        // JSON is NSARRAY
                       
                       
                        if let json = JSON as? [Any] {
                            self.itemSearchSuggestion = []
                            if json.count > 0 {
                                for case let  item as [String : Any] in json{
                                    self.itemSearchSuggestion.append(SuggestSearchModel(json:item)!)
                                }
                            }else{
                                // Result is empty
                                AlertService.sharedInstance.process(AppConstants.MESSAGE_NO_RESULT_FOUND,titleAllert:AppConstants.ALERT_DIALOG_TITLE_MESSAGE)
                            }
                        self.dispatch("SearchService.show.Success",data: self.itemSearchSuggestion as AnyObject?)
                            /*
                            if(self.searchController != nil){
                                self.searchController!.itemSearchSuggestion = self.itemSearchSuggestion
                                self.searchController!.tableView.reloadData()
                            }
                            */
                        }else{
                            if let _ = JSON as? [String:String]{
                            self.dispatch("SearchService.show.Success",data: nil)
                            }else{
                              print("Something wrong - json must be NSARRAY for requrest " + self.api!["URL_SEARCH","hasToken"])
                            }
                          
                        }
                
                        
                      
                        
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode  {
                            if statusCode == 404 {
                              self.dispatch("SearchService.show.Success",data: nil)
                            }
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

        }else{
            AlertService.sharedInstance.process(ValidateService.sharedInstance.getLastMessage())
        }
    }
    
}
