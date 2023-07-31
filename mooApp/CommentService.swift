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

open class CommentService : AppService {
    // Mark: Properties
    var objectId:String?
    var objectType:String?
    var message:String?
    var photo:String?
    var images:[UIImage] = []


    var isShowProcessingNotifcation = false
    
    
   
    
    //let banner = StatusBarNotificationBanner(title: "Posting status is processing.", style: .success)
    var banner:StatusBarNotificationBanner?
    
    //let api = AppConfigService.sharedInstance.apiSetting
    // Mark: init
    override init() {
        super.init()
        let title = NSLocalizedString("comment_status_processing",comment:"comment_status_processing")
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(NSForegroundColorAttributeName,
                                     value: UIColor.gray,
                                     range: NSMakeRange(0,(title as NSString).length))
        self.banner = StatusBarNotificationBanner(attributedTitle: attributedTitle, style: .success, colors: CustomBannerColors())
    }
    // Mark: Singleton
    class var sharedInstance : CommentService {
        struct Singleton {
            static let instance = CommentService()
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
                            self.photo = photo
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
            /*
             data[target_id]:2
             data[type]:Blog_Blog
             data[message]:has comment @[59:Gerard 't Hooft]
             thumbnail:uploads/tmp/c0d6b8b3a7aebba2efa23cb49f9569c7.png
             */
            let parameters:Parameters = [
                "id":objectId ?? "",
                "text":message ?? "",
                "photo":photo ?? "",
            ]
            var uri:String?
            
            if objectType?.lowercased() == "activity" || objectType?.lowercased() == "activity_link"   {
             uri = (api!["URL_POST_ACTIVITY_COMMENT","hasToken"]).replacingOccurrences(of: ":id",with:objectId! );
            }else{
                
             uri = (api!["URL_POST_COMMENT","hasToken"]).replacingOccurrences(of: ":objectType",with:self.objectType ?? "");
            }
        
            AlamofireService.sharedInstance.privateSession!.request( uri!,method:.post,parameters: parameters,encoding:JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success( _):
                          self.dispatch("CommentService.post.Success")
                    
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
}

