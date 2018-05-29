//
//  PATELHandlea.swift
//  wanjia2B
//
//  Created by lichao_liu on 17/2/15.
//  Copyright © 2017年 pingan. All rights reserved.
//

import UIKit

class PATELHandle {
    
    static let sharedTELHandle:PATELHandle = PATELHandle()
    lazy var webView:UIWebView = {
       return UIWebView(frame: CGRect.zero)
    }()
    
    func tel(phoneNumber:String) {
        let str = String(format: "tel://%@",PATELHandle.cleanPhoneNumber(mobile: phoneNumber))
        if let url = URL(string: str){
            if UIApplication.shared.canOpenURL(url){
                webView.loadRequest(URLRequest(url: url))
            }else{
                //你的设备不支持打电话
            }
        }
    }
    
    static func cleanPhoneNumber(mobile: String) -> String {
        return mobile.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }
}
