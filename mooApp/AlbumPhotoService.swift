//
//  AlbumService.swift
//  mooApp
//
//  Created by tuan on 6/26/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import Alamofire
import NotificationBannerSwift

open class AlbumPhotoService : AppService {
    var photos : [String] = []
    var inputImages : [UIImage] = []
    var target_id : Int = 0
    var type : String = "Photo_Album"
    var dispatchGroup = DispatchGroup()
    var banner:StatusBarNotificationBanner?
    var isShowProcessingNotifcation = false
    
    // Mark: init
    override init() {
        super.init()
        
        let title = NSLocalizedString("album_photo_saving_photo",comment:"album_photo_saving_photo")
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(NSForegroundColorAttributeName,
                                     value: UIColor.gray,
                                     range: NSMakeRange(0,(title as NSString).length))
        self.banner = StatusBarNotificationBanner(attributedTitle: attributedTitle, style: .success, colors: CustomBannerColors())
    }
    
    func postAlbumPhoto(image:UIImage?){
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
            
        },to: api!["URL_UPLOAD_ALBUM_PHOTO","hasToken"],encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let data = response.result.value as? NSDictionary {
                        if let photo = data["photo"] as? String{
                            self.photos.append(photo)
                        }
                    }
                    self.dispatchGroup.leave()
                }
            case .failure(let encodingError):
                print(encodingError)
                self.dispatchGroup.leave()
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
    
    func saveAlbumPhoto(){
        var parameters:Parameters = [
            "target_id": self.target_id,
            "type": self.type
        ]
        if !photos.isEmpty{
            parameters["photos"] = self.photos.joined(separator: ",")
        }
        AlamofireService.sharedInstance.privateSession!.request( api!["URL_SAVE_ALBUM_PHOTO","hasToken"],method:.post,parameters: parameters,encoding:JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    self.dispatch("PhotoService.album.savephoto.Success")
                case .failure(let error):
                    if let data = response.data {
                        if let JSONDictionary = JsonService.sharedInstance.convertToNSDictionary(data){
                            AlertService.sharedInstance.process(JSONDictionary.value(forKey: "message") as! String)
                            print("\(error)")
                        }
                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                        
                    }
                    self.dispatch("PhotoService.album.savephoto.Failure")
                }
                
                if self.isShowProcessingNotifcation{
                    self.isShowProcessingNotifcation = false
                    self.banner?.dismiss()
                }
        }
    }
    
    func doPost(){
        if self.inputImages.count > 0{
            if !isShowProcessingNotifcation{
                isShowProcessingNotifcation = true
                banner?.duration = 1000000.0
                banner?.show()
            }
            
            for  image in self.inputImages{
                self.dispatchGroup.enter()
                self.postAlbumPhoto(image: image)
            }
            
            //Called when all the requests are finished
            self.dispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
                self.saveAlbumPhoto()
            }
        }
    }
}
