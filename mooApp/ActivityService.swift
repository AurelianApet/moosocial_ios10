//
//  FriendService.swift
//  mooApp
//
//  Created by duy on 5/5/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import Alamofire
import NotificationBannerSwift

open class ActivityService : AppService {
    // Mark: Properties
    var images:[UIImage] = []
    var status:String = ""
    var photos:[String] = []
    var isShowProcessingNotifcation = false
    var message:String?
    var messageText:String?
    var userShareLink:String?
    var privacy:Int = 1
    var userTaging:[Int] = []
    var WhatsNewWKController: WhatsNewWKViewController?
    
    //let banner = StatusBarNotificationBanner(title: "Posting status is processing.", style: .success)
    var banner:StatusBarNotificationBanner?

    //let api = AppConfigService.sharedInstance.apiSetting
    // Mark: init
    override init() {
        super.init()
        let title = NSLocalizedString("post_status_processing",comment:"post_status_processing")
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(NSForegroundColorAttributeName,
                                     value: UIColor.gray,
                                     range: NSMakeRange(0,(title as NSString).length))
        self.banner = StatusBarNotificationBanner(attributedTitle: attributedTitle, style: .success, colors: CustomBannerColors())
    }
    // Mark: Singleton
    class var sharedInstance : ActivityService {
        struct Singleton {
            static let instance = ActivityService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    // Mark: Post image
    /*
     * Post images
     */
    func postImage(_ image:UIImage?){
        if !isShowProcessingNotifcation{
            isShowProcessingNotifcation = true
            banner?.duration = 1000000.0
            banner?.show()
        }

        AlamofireService.sharedInstance.privateSession!.upload(multipartFormData: {
            multipartFormData in
            
            if let _image = image {
                var imageData:Data?
                if  _image.size.width > CGFloat(1920) {
                    let __image = self.scale(sourceImage: _image,scaledToWidth: 1920)
                    imageData = UIImageJPEGRepresentation(__image, 0)!
                }else{
                    imageData = UIImageJPEGRepresentation(_image, 0)!
                }
                if let _imageData = imageData {
                    multipartFormData.append(_imageData, withName: "qqfile", fileName: "file.png", mimeType: "image/png")
                }
            }
            /*
             for (key, value) in parameters {
             multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
             }
             */
            
        },to: api!["URL_FILE","hasToken"],encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    if let data = response.result.value as? NSDictionary {
                        /*
                        if let error = data["error"] as? String{
                            AlertService.sharedInstance.process(error )
                        }else{
                            self.dispatch("UserService.saveAvatar.Success",data: data as AnyObject?)
                        }
                        */
                        if let photo = data["photo"] as? String{
                            self.photos.append(photo)
                        }
                    }
                    self.post()
                }
                
                
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    func scale(sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    // Mark: Post status
    /*
     * Post images
     */
    func post(){
        
        if images.count > 0 {
            let image = images.removeFirst()
            postImage(image)
        }else{
            
            var parameters:Parameters = [
                "message":self.message ?? "",
                "messageText":self.messageText ?? "",
                "wallPhoto":self.photos,
                "privacy":self.privacy
            ]
            if !self.userTaging.isEmpty{
                parameters["userTagging"] = self.userTaging.map(String.init).joined(separator: ",")
            }
            if self.userShareLink != nil {
                parameters["userShareLink"] = self.userShareLink
            }
            AlamofireService.sharedInstance.privateSession!.request( api!["URL_WALL_POST_STATUS","hasToken"],method:.post,parameters: parameters,encoding:JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success( _):
                           
                           self.WhatsNewWKController?.doRefeshWebview()
                    case .failure(let error):
                        self.dispatch("AuthenticationService.identifyUser.forceLogin.Failure")
                        if let data = response.data {
                            if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                                AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                                print("\(error)")
                            }
                            print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                            
                        }
                        
                    }
                    if self.isShowProcessingNotifcation{
                        self.isShowProcessingNotifcation = false
                        self.banner?.dismiss()
                    }
                    
                    
            }
        }
    }
    // MARK: Fetch a link
    /*
     * Paramaters : 
     * url : String
     */
    func fetch(_ url:String){
        let parameters:Parameters = [
            "content":url,
        ]
        self.dispatch("ActivityService.Before.FetchLink",data:nil)
        AlamofireService.sharedInstance.privateSession!.request( api!["URL_GET_ACTIVITY_FETCH_LINK","hasToken"],method:.post,parameters: parameters,encoding:JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success( let JSON):
                    if var data = JSON as? [String:String]{
                        data["url"] = url
                        self.dispatch("ActivityService.FetchLink.Success",data:data as AnyObject)
                    }else{
                        self.dispatch("ActivityService.FetchLink.Success",data:nil)
                    }
                    
                case .failure(let error):
                    self.dispatch("ActivityService.FetchLink.Failed")
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

class CustomBannerColors: BannerColorsProtocol {
    
    public func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:   return UIColor(red:0.90, green:0.31, blue:0.26, alpha:1.00)
        case .info:     return UIColor(red:0.23, green:0.60, blue:0.85, alpha:1.00)
        case .none:     return UIColor.clear
        case .success:  return UIColor.white
        case .warning:  return UIColor(red:1.00, green:0.66, blue:0.16, alpha:1.00)
        }
    }
    
}
