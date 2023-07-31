//
//  ImageService.swift
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
import AlamofireImage

protocol ImageServiceAsynchronouslyDelegate{
    func doAfterGetAsynchronously(_ image:UIImage?)
}
open class ImageService : AppService {
    // Mark : Propetites 
    let imageCache = AutoPurgingImageCache()
    // Mark: Singleton
    class var sharedInstance : ImageService {
        struct Singleton {
            static let instance = ImageService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
    func get(_ url:String,newWidth:CGFloat = CGFloat()) -> UIImage?{
        let imgURL: URL = URL(string: url)!
        
        if let uiImage = UIImage(data:try! Data(contentsOf: imgURL)) {
            if newWidth != CGFloat(){
                return resizeImage(uiImage,newWidth: newWidth)
            }
            
            return uiImage
        }
        return nil
        
    }
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    // We have prolem with Synchronously image is the cause of the lacking of  notification view
    func getAsynchronouslyDataFromUrl(_ url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
        print("/Users/duy/Documents/ios-deploy/community.moosocial.com/ios-app/mooApp/ImageService.swift:58:27: Cannot invoke 'dataTask' with an argument list of type '(with: URL, completionHandler: (Data?, URLResponse?, Error?) -> Void)'")
        /*URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            completion(data, response, error)
            }) .resume()
        */
    }
    func getAsynchronously(_ object:UIImageView?,url: String,newWidth:CGFloat = CGFloat(),callback:ImageServiceAsynchronouslyDelegate?=nil){
        if url != ""{
            let URLRequest = Foundation.URLRequest(url: URL(string: url)!)
            
            if var img =  imageCache.image(for:URLRequest){
                if newWidth != CGFloat(){
                    img = self.resizeImage(img,newWidth: newWidth)
                }
                
                if object != nil{
                    object!.image = img
                }
                
                if callback != nil{
                    callback?.doAfterGetAsynchronously(img)
                }
                
            }else{
                
                Alamofire.request(url).responseImage { response in
                    if let image = response.result.value {
                        
                        self.imageCache.add(image,for: URLRequest)
                        self.getAsynchronously(object,url: url,newWidth: newWidth,callback: callback)
                    }
                }
                
            }
        }
    }
}
