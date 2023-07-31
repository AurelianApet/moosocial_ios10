//
//  SZDefaultAttributes.swift
//  mooApp
//
//  Created by duy on 5/3/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import UIKit
internal class SZDefaultAttributes {
    /**
     @brief Default color
     */
    static var defaultColor: SZAttribute {
        return SZAttribute(attributeName: NSForegroundColorAttributeName,
                           attributeValue: UIColor.black)
    }
    
    /**
     @brief Mention color
     */
    static var mentionColor: SZAttribute {
        return SZAttribute(attributeName: NSForegroundColorAttributeName,
                           attributeValue: UIColor.blue)
    }
    
    /**
     @brief the text attributes to be applied to default text (can be overridden using inits on SZMentionsListener)
     */
    static var defaultTextAttributes: [SZAttribute] { return [defaultColor] }
    
    /**
     @brief the text attributes to be applied to mention text (can be overridden using inits on SZMentionsListener)
     */
    static var defaultMentionAttributes: [SZAttribute] { return [mentionColor] }
}
