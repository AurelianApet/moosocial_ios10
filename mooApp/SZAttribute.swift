//
//  SZAttribute.swift
//  mooApp
//
//  Created by duy on 5/3/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation

public class SZAttribute {
    /**
     @brief Name of the attribute to set on a string
     */
    private(set) var attributeName: String
    
    /**
     @brief Value of the attribute to set on a string
     */
    private(set) var attributeValue: NSObject
    
    /**
     @brief initializer for creating an attribute
     @param attributeName: the name of the attribute (example: NSForegroundColorAttributeName)
     @param attributeValue: the value for the given attribute (example: UIColor.redColor)
     */
    public init(attributeName: String, attributeValue: NSObject) {
        self.attributeName = attributeName
        self.attributeValue = attributeValue
    }
}
