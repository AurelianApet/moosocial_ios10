//
//  AlamofireService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
import Alamofire
// Automatically adding language for all api request 
open class MooManager : Alamofire.SessionManager{
    open  override func request(
        _ URLString: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest
    {
        do{
            //parameters!["language"] = SharedPreferencesService.sharedInstance.getCurrentSystemLanggaue()
            var URLString = URLString
            var parameters = parameters
            switch method {
            case .get:
                let url = try URLString.asURL()
                
                if url.absoluteString.range(of: "?") == nil{
                    URLString = url.absoluteString +  "?language=" + SharedPreferencesService.sharedInstance.getCurrentSystemLanggaue()
                }else{
                    URLString = url.absoluteString +   "&language=" + SharedPreferencesService.sharedInstance.getCurrentSystemLanggaue()
                    
                }
            case .post:
                
                if parameters != nil{
                    
                    parameters!["language"] = SharedPreferencesService.sharedInstance.getCurrentSystemLanggaue()
                }else{
                    parameters = ["language":SharedPreferencesService.sharedInstance.getCurrentSystemLanggaue()]
                }
            default: break
                
            }
            return super.request(URLString,method:method,parameters: parameters, encoding: encoding, headers: headers)
        } catch {
            return request(error as! URLRequestConvertible)
        }
        
    }
}
open class AlamofireService : NSObject {
    var privateSession:MooManager?
    // Mark: init
    override init() {
        super.init()
        var defaultHeaders = SessionManager.defaultHTTPHeaders
 
        defaultHeaders["User-Agent"] = (defaultHeaders["User-Agent"]! as String) + " mooIOS/1.0"
        
        
        
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = defaultHeaders
        privateSession = MooManager(configuration: configuration)
    }
    // Mark: Singleton
    class var sharedInstance : AlamofireService {
        struct Singleton {
            static let instance = AlamofireService()
        }
        
        
        // Return singleton instance
        return Singleton.instance
    }
}

