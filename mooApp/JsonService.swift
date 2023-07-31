//
//  JsonService.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit
import Foundation
open class JsonService : NSObject {
    
    // Mark: Singleton
    class var sharedInstance : JsonService {
        struct Singleton {
            static let instance = JsonService()
        }
        // Return singleton instance
        return Singleton.instance
    }
    
    func convertToNSDictionary(_ data:Data)->NSDictionary?{
        let JSONData : Data = data
        
        do {
            let JSON = try JSONSerialization.jsonObject(with: JSONData, options:JSONSerialization.ReadingOptions(rawValue: 0))
            guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {

                return nil
            }
            return JSONDictionary
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
        return nil
    }
    
}
