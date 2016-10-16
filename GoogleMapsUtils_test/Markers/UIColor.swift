//
//  UIColor.swift
//  
//
//  Created by alex on 05/10/16.
//
//

import UIKit

public extension UIColor {
    
    public convenience init(hexValue: UInt64) {
        self.init(red: ((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hexValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(hexValue & 0xFF))/255.0, alpha: 1)
    }
    
    public class func colorFromHexValue(hexValue:UInt64) -> UIColor {
        let color = UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hexValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(hexValue & 0xFF))/255.0, alpha: 1)
        return color;
    }
}