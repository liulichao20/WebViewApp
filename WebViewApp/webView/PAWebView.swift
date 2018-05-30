//
//  PAWebView.swift
//  WebViewApp
//
//  Created by lichao_liu on 2018/5/28.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit
import WebKit
@objc protocol PAWebViewDelegate:NSObjectProtocol {
    @objc optional func webView(_ webView:PAWebView,didChangeTitle title:String?)
    @objc optional func webView(_ webView:PAWebView,didChangeURL url:URL?)
    @objc optional func webViewDidGoBackChange(_ webView:PAWebView,didChangeBackFlag:Bool)
    @objc optional func webViewDidStartLoad(for webView:PAWebView)
    @objc optional func webViewDidFinishLoad(for webView:PAWebView)
    @objc optional func webViewDidFailLoad(_ webView:PAWebView,error:Error)
    @objc optional func webViewShouldStartLoad(_ webView:PAWebView,request:URLRequest)->Bool
    @objc optional func webView(_ webView:PAWebView,messageName:String,body:Any)//与js交互
}
class PAWebView:NSObject {
    var webViewDelegate:PAWebViewDelegate?
    var wkWebView:WKWebView!
    private let observerKeys:[String] = ["URL","title","canGoBack"]
    //与js交互的messagename列表
    private var scriptMessages:[String]?
    //注入的js
    private var scriptSources:[String]?
    init(scriptMessages:[String]?=nil,scriptSouces:[String]?=nil) {
        super.init()
        
        self.scriptMessages = scriptMessages
        self.scriptSources = scriptSouces
        
        let config = WKWebViewConfiguration()
        config.processPool = PACookieSyncManager.sharedInstance.createProcessPool()
        config.allowsInlineMediaPlayback = true
        config.mediaPlaybackRequiresUserAction = false
        let userContentController = WKUserContentController()
        if let messages = scriptSouces,!messages.isEmpty {
            messages.forEach({
                userContentController.add(self, name: $0)
            })
        }
        if let sources = scriptSources,!sources.isEmpty {
            sources.forEach({
                userContentController.addUserScript(WKUserScript(source: $0, injectionTime: .atDocumentStart, forMainFrameOnly: true))
            })
        }
        let javascript = "document.documentElement.style.webkitTouchCallout='none';document.documentElement.style.webkitUserSelect='none';"
        let script = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(script)
        config.userContentController = userContentController
        wkWebView = WKWebView(frame: .zero, configuration: config)
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        addObserver()
    }
    
    func removeScriptMessages() {
        if let messages = scriptSources,!messages.isEmpty {
            messages.forEach({
                wkWebView.configuration.userContentController.removeScriptMessageHandler(forName: $0)

            })
        }
    }
    
    func addObserver() {
        observerKeys.forEach {
            wkWebView.addObserver(self, forKeyPath: $0, options: .new, context: nil)
        }
    }
    
    func removeOserver() {
        observerKeys.forEach {
            wkWebView.removeObserver(self, forKeyPath: $0)
        }
    }
    
    func loadRequest(request:URLRequest){
        wkWebView.load(request)
    }
    
    func goBack(){
        wkWebView.goBack()
    }
    
    func canGoBack()->Bool {
        return wkWebView.canGoBack
    }
    
    func reload(){
        wkWebView.reload()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {return}
        switch keyPath {
        case "URL":
            webViewDelegate?.webView?(self, didChangeURL: wkWebView.url)
        case "title":
            webViewDelegate?.webView?(self, didChangeTitle: wkWebView.title)
        case "canGoBack":
            if let val = change?[NSKeyValueChangeKey.newKey] as? Bool {
                webViewDelegate?.webViewDidGoBackChange?(self, didChangeBackFlag: val)
            }
            
        default:
            break
        }
    }
    
    deinit {
        removeOserver()
    }
}

extension PAWebView:WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webViewDelegate?.webViewDidStartLoad?(for: self)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if !webView.isLoading {
            webViewDelegate?.webViewDidFailLoad?(self, error: error)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewDelegate?.webViewDidFinishLoad?(for: self)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString == "about:blank" {
                decisionHandler(.cancel)
                return
            }
            if webViewDelegate?.webViewShouldStartLoad?(self, request: navigationAction.request) == false {
                decisionHandler(.cancel)
                return
            }
            if url.absoluteString.contains("//itunes.apple.com") || url.scheme == "wangyin"{
                UIApplication.shared.openURL(url)
                decisionHandler(.cancel)
                return
            }
            if url.scheme == "tel" || url.scheme == "sms"{
                if let range = url.absoluteString.range(of: ":"){
                    let target = url.absoluteString.substring(from: range.upperBound)
                    if url.scheme == "tel"{
                        PATELHandle.sharedTELHandle.tel(phoneNumber: target)
                    }else if url.scheme == "sms"{
                        if let controller = AppDelegate.sharedDelegate.window?.rootViewController{
                            PASMSHandle.sharedSMSHandle.sms(phoneNumber: target, controller: controller)
                        }
                    }
                }
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    //内存报警
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    //表现为重新打开一个网页，然后加载此URL
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url?.description.lowercased(),url.contains("http") {
                webView.load(URLRequest.init(url: navigationAction.request.url!))
            }
        }
        return nil
    }
}

extension PAWebView:WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        webViewDelegate?.webView?(self, messageName: message.name, body: message.body)
    }
}

extension PAWebView:WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if message.isEmpty { return }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "好的", style: .default) { alertAction in
            completionHandler()
        }
        alert.addAction(action)
        if let controller = AppDelegate.sharedDelegate.window?.rootViewController{
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        if message.isEmpty { return }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "好的", style: .default) { alertAction in
            completionHandler(true)
        }
        alert.addAction(action)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { alertAction in
            completionHandler(false)
        }
        alert.addAction(cancelAction)
        if let controller = AppDelegate.sharedDelegate.window?.rootViewController{
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if prompt.isEmpty && (defaultText ?? "").isEmpty { return }
        let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.textColor = UIColor.black
        }
        let sureAction = UIAlertAction(title: "好的", style: .default) { action in
            var result:String? = nil
            if let fields = alert.textFields, !fields.isEmpty{
                result = fields.first?.text
            }
            completionHandler(result)
        }
        alert.addAction(sureAction)
        if let controller = AppDelegate.sharedDelegate.window?.rootViewController{
            controller.present(alert, animated: true, completion: nil)
        }
    }
}
