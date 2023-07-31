//
//  AppModel.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import Foundation
/*
open class AppModel:NSObject{
    
    var lastLoadDictionary:NSDictionary?
    subscript(key:String,action:String)->String?{
        if (action.range(of: "limit:")  != nil){
            
        }
        return nil
    }
    func load( _ text:String?,dictionary:NSDictionary? = NSDictionary())-> Bool{
        var dictionary = dictionary
        if text != nil {
            let JSONData = text!.data(using: String.Encoding.utf8, allowLossyConversion: false)
            do {
                let JSON = try JSONSerialization.jsonObject(with: JSONData!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                    //print("Not a Dictionary")
                 return false
                }
                if dictionary == NSDictionary() {
                    dictionary = JSONDictionary
                }
            }
            catch let JSONError as NSError {
                print("\(JSONError)")
            }
            
        }
       
        if dictionary != nil {
            self.lastLoadDictionary = dictionary
            for (key, value) in dictionary! {
                let keyName = key as? String
                var keyValue:AnyObject?
                
                
                
                // If property exists
                if (self.responds(to: NSSelectorFromString(keyName!))) {
                    let type = getTypeOfProperty(keyName!)
                    
                    switch type {
                        case "Optional<String>":                    
                            keyValue = String(describing: value) as AnyObject?
                            
                            break
                        case "Optional<AnyObject>":
                            if let json = value as? NSDictionary {
                                                               keyValue = json
                            }else{
                                keyValue = nil
                            }
                        case "Bool":
                            if let bool = value as? Bool{
                                keyValue = bool as AnyObject?
                            }
                            break
                    default:
                        
                        keyValue = value as? String as AnyObject?
                        break
                    }

                    self.setValue(keyValue, forKey: keyName!)

                }
            }
        }
        return true;
    }
    func getTypeOfProperty(_ name:String)->String
    {
        let type = Mirror(reflecting:self)
        
        for child in type.children {
            if child.label! == name
            {
                return String(describing: type(of: (child.value) as AnyObject))
            }
        }
        return ""
    }
    open func formatKey(_ key: String) -> String {
        return key
    }
    
    open func formatValue(_ value: AnyObject?, forKey: String) -> AnyObject? {
        return value
    }
    
    func setValue(_ dictionary: NSDictionary, value: AnyObject?, forKey: String) {
        dictionary.setValue(formatValue(value, forKey: forKey), forKey: formatKey(forKey))
    }
    
    /**
     Converts the class to a dictionary.
     - returns: The class as an NSDictionary.
     */
    open func toDictionary() -> NSDictionary {
        let propertiesDictionary = NSMutableDictionary()
        let mirror = Mirror(reflecting: self)
        for (propName, propValue) in mirror.children {
            if let propValue: AnyObject = self.unwrap(propValue) as AnyObject, let propName = propName {
                if let serializablePropValue = propValue as? AppModel {
                    setValue(propertiesDictionary, value: serializablePropValue.toDictionary(), forKey: propName)
                } else if let arrayPropValue = propValue as? [AppModel] {
                    var subArray = [NSDictionary]()
                    for item in arrayPropValue {
                        subArray.append(item.toDictionary())
                    }
                    setValue(propertiesDictionary, value: subArray as AnyObject?, forKey: propName)
                } else if propValue is Int || propValue is Double || propValue is Float {
                    setValue(propertiesDictionary, value: propValue, forKey: propName)
                } else if let dataPropValue = propValue as? Data {
                    setValue(propertiesDictionary, value: dataPropValue.base64EncodedString(options: .lineLength64Characters) as AnyObject?, forKey: propName)
                } else if let datePropValue = propValue as? Date {
                    setValue(propertiesDictionary, value: datePropValue.timeIntervalSince1970 as AnyObject?, forKey: propName)
                } else if let boolPropValue = propValue as? Bool {
                    setValue(propertiesDictionary, value: boolPropValue as AnyObject?, forKey: propName)
                } else {
                    setValue(propertiesDictionary, value: propValue, forKey: propName)
                }
            }
            else if let propValue:Int8 = propValue as? Int8 {
                setValue(propertiesDictionary, value: NSNumber(value: propValue as Int8), forKey: propName!)
            }
            else if let propValue:Int16 = propValue as? Int16 {
                setValue(propertiesDictionary, value: NSNumber(value: propValue as Int16), forKey: propName!)
            }
            else if let propValue:Int32 = propValue as? Int32 {
                setValue(propertiesDictionary, value: NSNumber(value: propValue as Int32), forKey: propName!)
            }
            else if let propValue:Int64 = propValue as? Int64 {
                setValue(propertiesDictionary, value: NSNumber(value: propValue as Int64), forKey: propName!)
            }
            else if let propValue:UInt8 = propValue as? UInt8 {
                setValue(propertiesDictionary, value: NSNumber(value: propValue as UInt8), forKey: propName!)
            }
            else if let propValue:UInt16 = propValue as? UInt16 {
                setValue(propertiesDictionary, value: NSNumber(value: propValue as UInt16), forKey: propName!)
            }
            else if let propValue:UInt32 = propValue as? UInt32 {
                setValue(propertiesDictionary, value: NSNumber(value: propValue as UInt32), forKey: propName!)
            }
            else if let propValue:UInt64 = propValue as? UInt64 {
                setValue(propertiesDictionary, value: NSNumber(value: propValue as UInt64), forKey: propName!)
            }
        }
        
        return propertiesDictionary
    }
    
    /**
     Converts the class to JSON.
     - returns: The class as JSON, wrapped in NSData.
     */
    open func toJson(_ prettyPrinted : Bool = false) -> Data? {
        let dictionary = self.toDictionary()
        
        if JSONSerialization.isValidJSONObject(dictionary) {
            do {
                let json = try JSONSerialization.data(withJSONObject: dictionary, options: (prettyPrinted ? .prettyPrinted : JSONSerialization.WritingOptions()))
                return json
            } catch let error as NSError {
                //print("ERROR: Unable to serialize json, error: \(error)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "CrashlyticsLogNotification"), object: self, userInfo: ["string": "unable to serialize json, error: \(error)"])
            }
        }
        
        return nil
    }
    
    /**
     Converts the class to a JSON string.
     - returns: The class as a JSON string.
     */
    open func toJsonString(_ prettyPrinted : Bool = false) -> String? {
        if let jsonData = self.toJson(prettyPrinted) {
            return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
        }
        
        return nil
    }
    
    
    /**
     Unwraps 'any' object. See http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type
     - returns: The unwrapped object.
     */
    func unwrap(_ any:Any) -> Any? {
        
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .optional {
            return any
        }
        
        if mi.children.count == 0 { return nil }
        let (_, some) = mi.children.first!
        return some
    }

}
*/
protocol JSONRepresentable {
    var JSONRepresentation: AnyObject { get }
}
protocol JSONSerializable: JSONRepresentable {
}
extension JSONSerializable {
    var JSONRepresentation: AnyObject {
        var representation = [String: AnyObject]()
        
        for case let (label?, value) in Mirror(reflecting: self).children {
            switch value {
            case let value as JSONRepresentable:
                representation[label] = value.JSONRepresentation
                
            case let value as NSObject:
                representation[label] = value
                
            default:
                // Ignore any unserializable properties
                break
            }
        }
        
        return representation as AnyObject
    }
}
extension JSONSerializable {
    func toJSON() -> String? {
        let representation = JSONRepresentation
        
        guard JSONSerialization.isValidJSONObject(representation) else {
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: representation, options: [])
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }
}
