//
//  NSMutableAttributedString+Attributes.swift
//  mooApp
//
//  Created by duy on 5/3/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
internal extension NSMutableAttributedString {
    /**
     @brief Applies attributes to a given string and range
     @param attributes: the attributes to apply
     @param range: the range to apply the attributes to
     @param mutableAttributedString: the string to apply the attributes to
     */
    func apply(_ attributes: [SZAttribute], range: NSRange) {
        attributes.forEach { attribute in
            addAttribute(attribute.attributeName,
                         value: attribute.attributeValue,
                         range: range)
        }
    }
}
