//
//  PACookieSyncManager.swift
//  WebViewApp
//
//  Created by lichao_liu on 2018/5/28.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit
import WebKit

class PACookieSyncManager {
    static var sharedInstance : PACookieSyncManager = PACookieSyncManager()
    var processPool:WKProcessPool?
    
    func createProcessPool()->WKProcessPool{
        if processPool == nil{
            processPool = WKProcessPool()
        }
        return processPool!
    }
    
    func clearCookie() {
        processPool = nil
        
        let dateFrom: Date = Date.init(timeIntervalSince1970: 0)
        if #available(iOS 9.0, *) {
            let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
            }
        } else {
            let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
            let cookiesFolderPath = libraryPath + "/Cookies"
            try? FileManager.default.removeItem(atPath: cookiesFolderPath)
        }
        
    }
}


