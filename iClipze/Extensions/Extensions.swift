//
//  Extensions.swift
//  iClipze
//
//  Created by Michelle Grover on 3/12/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    static let pink = UIColor.colorFromHex("FE069A")
    static let myblue = UIColor.colorFromHex("33D2FC")
    static let myWhite = UIColor.colorFromHex("FFFFFF")
    static let grossGreen = UIColor.colorFromHex("CFD73E")
    static let offOrange = UIColor.colorFromHex("FDA833")
    
    static func colorFromHex(_ hex:String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (hexString.hasPrefix("#")) {
            hexString.remove(at: hexString.startIndex)
        }
        
        if (hexString.count != 6) {
            return UIColor.black
        }
        
        var rgb:UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: 1.0)
        
    }
    
    
    
}

// MARK:- NSAttributedString
extension NSAttributedString {
    
    
    static func iClipzeAttributedString(foreground:UIColor, background:UIColor) -> [NSAttributedString.Key : Any] {
        let attributes = [
            NSAttributedString.Key.underlineStyle : 0,
            NSAttributedString.Key.foregroundColor : foreground,
            NSAttributedString.Key.backgroundColor : background,
            NSAttributedString.Key.textEffect : NSAttributedString.TextEffectStyle.letterpressStyle,
            NSAttributedString.Key.strokeWidth : 1.0
            ] as [NSAttributedString.Key : Any]
        return attributes
    }
}
