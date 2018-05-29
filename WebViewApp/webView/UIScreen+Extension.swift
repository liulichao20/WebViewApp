//
//  UIScreen+Extension.swift
//  WebViewApp
//
//  Created by lichao_liu on 2018/5/29.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

extension UIScreen {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let navigationBarHeight: CGFloat = 44
    static var statusHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    static var navigationHeight: CGFloat {
        return statusHeight + navigationBarHeight
    }
 }
