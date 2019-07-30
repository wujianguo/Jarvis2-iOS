//
//  UIConstants.swift
//  NeteaseIM
//
//  Created by Jianguo Wu on 2018/5/25.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import Foundation
import UIKit


struct UIConstants {
    
}

extension UIConstants {
    static let padding:CGFloat  = 8
    static let themeColor       = UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 1)
    static let destructiveColor = UIColor.red
}

extension UIColor {
    
    func lighter() -> UIColor {
        var red:   CGFloat = 0
        var green: CGFloat = 0
        var blue:  CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: min(red+0.2, 1), green: min(green+0.2, 1), blue: min(blue+0.2, 1), alpha: alpha)
    }

    func darker() -> UIColor {
        var red:   CGFloat = 0
        var green: CGFloat = 0
        var blue:  CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: max(red-0.2, 0), green: max(green-0.2, 0), blue: max(blue-0.2, 0), alpha: alpha)
    }
}
