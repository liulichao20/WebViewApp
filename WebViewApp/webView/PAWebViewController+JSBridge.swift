//
//  PAWebViewController+JSBridge.swift
//  WebViewApp
//
//  Created by lichao_liu on 2018/5/29.
//  Copyright © 2018年 com.pa.com. All rights reserved.
// 获取h5数据有2种方法
//1 通过拦截请求，执行executeJSBridge拿到对应数据
//2 通过配置script数据 通过webView(_ webView:PAWebView,messageName:String,body:Any) 拿到
//建议用第2种方法

import UIKit
//拦截请求
extension PAWebViewController {
    func executeJSBridge(requestString str:String)->Bool {
        //eg: appscheme://functionName?a=urlencodeA&b=urlencodeB&...
        if str.hasPrefix("appscheme://") {
            let components = str.components(separatedBy: "://")
            if components.count >= 2 {
                let functionNameAndParams = components[1].components(separatedBy: "?")
                let functionName = functionNameAndParams[0]
                let params = queryComponents(urlStr: str)
                return handleFunction(functionName: functionName, params: params)
            }
        }else {
            //MARK: --DO WHAT YOU WANT
            
        }
        return true
    }
    
    func queryComponents(urlStr: String) -> [String: String] {
        var components: [String: String] = [:]
        guard let url = URL(string: urlStr),
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
                return components
        }
        queryItems.forEach {
            if !$0.name.isEmpty {
                components[$0.name] = $0.value ?? ""
            }
        }
        return components
    }
    
    func handleFunction(functionName:String,params:[String:String])->Bool{
        switch functionName {
        case "share":
            //do share action
            return false
        case "apply":
            //do apply action
            return false
        default:
            break
        }
        return true
    }
}
//usercontentcontroller
extension PAWebViewController {
    func dealUserContentController(messageName:String,body:Any){
        //body 支持NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull
        switch messageName {
        case "messageName":
            if body is [String:Any]{
                print(body)
            }
        default:
            break
        }
    }
}
