//
//  PAWebViewController.swift
//  WebViewApp
//
//  Created by lichao_liu on 2018/5/28.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit
import NJKWebViewProgress

enum PAWebViewTitleLevel:Int {
    case document
    case higher
}
class PAWebViewController: UIViewController{
    var webUrl:URL?
    var webView:PAWebView!
    ///  将allowsBackForwardNavigationGestures属性移动到这里
    ///  因为在iOS8.3 上，allowsBackForwardNavigationGestures设置为true后，不能再设置为false
    ///  否则web点击会崩溃
    var allowsBackForwardNavigationGestures: Bool {
        get {
            return webView.wkWebView.allowsBackForwardNavigationGestures
        }
        set(value) {
            webView.wkWebView.allowsBackForwardNavigationGestures = value
        }
    }
    
    lazy var progressView:NJKWebViewProgressView = {
        let progressView:NJKWebViewProgressView = NJKWebViewProgressView(frame: CGRect(x: 0, y: self.paNavigationBarHidden ? UIScreen.statusHeight - 2 : 43, width: self.view.bounds.size.width, height: 2))
        progressView.isHidden = true //先隐藏，避免闪烁
        progressView.autoresizingMask = [.flexibleTopMargin,.flexibleWidth]
        progressView.progressBarView.backgroundColor = UIColor.orange
        progressView.progress = 0
        return progressView
    }()
    //是否需要隐藏navigationbar
    var paNavigationBarHidden: Bool = false
    var isNeedShowBackBtn:Bool = true //是否显示返回按钮 关闭按钮
    private var isProgressing:Bool = false//进度条状态
    private var isLoaded:Bool = false //页面状态
    //title优先级：webHIgherTitle<-documentTitle<-title
    fileprivate var webHigherTitle:String?
    fileprivate var documentTitle:String?
    fileprivate var saveImage:UIImage?
    
    required init(urlString url:String?,allowsBackForwardNavigationGestures:Bool = true) {
        super.init(nibName: nil, bundle: nil)
        if let url = url,url.count>0{
            webUrl = URL(string: url)
        }
        let script = configScriptMessage()
        webView = PAWebView(scriptMessages: script?.scriptMessages, scriptSouces: script?.scriptSouces)
        webView.webViewDelegate = self
        self.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if paNavigationBarHidden {
            navigationController?.view.addSubview(progressView)
            webView.wkWebView.frame = CGRect(x: 0, y: UIScreen.statusHeight, width: UIScreen.width, height: UIScreen.height - UIScreen.statusHeight)
        }else{
            navigationController?.navigationBar.addSubview(progressView)
            webView.wkWebView.frame = CGRect(x: 0, y: UIScreen.navigationHeight, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationHeight)
        }
        addLongGesture()
        view.addSubview(webView.wkWebView)
        if webUrl != nil{
            webView.loadRequest(request: URLRequest(url: webUrl!))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(paNavigationBarHidden, animated: animated)
    }
    
    //MARK: - 设置与h5交互信息
    func configScriptMessage()->(scriptMessages:[String]?,scriptSouces:[String]?)? {
        //        var script:(scriptMessages:[String]?,scriptSouces:[String]?)
        //        script.scriptMessages = ["detailShare","shareMessage","personInformation"]
        //        script.scriptSouces = ["alert('在载入webview时通过Objective-C注入的JS方法');"]
        //        return script
        return nil
    }
    
    func addLongGesture() {
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        longGesture.minimumPressDuration = 1
        longGesture.delegate = self
        webView.wkWebView.addGestureRecognizer(longGesture)
    }
    
    @objc func handleLongPress(sender:UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        let touchPoint = sender.location(in: webView.wkWebView)
        let imgJS = String.init(format: "document.elementFromPoint(%f, %f).src", touchPoint.x,touchPoint.y)
        webView.wkWebView.evaluateJavaScript(imgJS) { (imageUrl, error) in
            if let imageUrl = imageUrl as? String,let url = URL(string: imageUrl) {
                if let data = try? Data(contentsOf: url),let image = UIImage(data: data){
                    //获取到图片
                    let alert = UIAlertController(title: nil, message: "图片操作", preferredStyle: .actionSheet)
                    self.saveImage = image
                    if let imageUrl = PAScanHelper.scanQRImage(image: image) {
                        let alertAction = UIAlertAction(title: "识别图片", style: .default, handler: { action in
                            print("识别图片 \(imageUrl)")
                        })
                        alert.addAction(alertAction)
                    }
                    let alertAction = UIAlertAction(title: "保存", style: .default, handler: { action in
                        print("保存")
                    })
                    alert.addAction(alertAction)
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setWebView(title:String?, level:PAWebViewTitleLevel){
        if let title = title {
            if level == .document{
                documentTitle = title
            }else if level == .higher{
                webHigherTitle = title
            }
            if webHigherTitle != nil{
                self.title = webHigherTitle
            }else if documentTitle != nil{
                self.title = documentTitle
            }
        }
    }
    
    func startProgress(){
        if self.isProgressing{
            return
        }
        isProgressing = true
        if !isLoaded{
            progressView.isHidden = false
            progressView.frame = CGRect(x: 0, y: self.paNavigationBarHidden ? (UIScreen.statusHeight - 2) : 43, width: self.view.bounds.size.width, height: 2)
            progressView.barAnimationDuration = 3
            progressView.setProgress(progress: 0.6, animated: true, completion: { [weak self]finished in
                if let strongSelf = self{
                    if !strongSelf.isLoaded{
                        strongSelf.progressView.barAnimationDuration = 3
                        strongSelf.progressView.setProgress(progress: 0.8, animated: true, completion: { finished in
                            if !strongSelf.isLoaded{
                                strongSelf.progressView.barAnimationDuration = 4
                                strongSelf.progressView.setProgress(progress: 0.9, animated: true, completion: { finished in
                                    strongSelf.isProgressing = false
                                })
                            }
                        })
                    }
                }
            })
        }
    }
    
    func finishProgress(){
        isLoaded = true
        progressView.frame = CGRect(x: 0, y: self.paNavigationBarHidden ? (UIScreen.statusHeight - 2) : 43, width: self.view.bounds.size.width, height: 2)
        progressView.barAnimationDuration = 0.25
        progressView.progressBarView.layer.removeAllAnimations()
        progressView.setProgress(progress: 0.99, animated: true) { [weak self]finished in
            if let strongSelf = self{
                strongSelf.progressView.setProgress(progress: 1, animated: true, completion: { finished in
                    strongSelf.isProgressing = false
                })
            }
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil{
            progressView.removeFromSuperview()
            webView.wkWebView.configuration.userContentController.removeAllUserScripts()
        }
    }
    
    func operatorLeftBtns(needShow:Bool){
        if !needShow{
            if !isNeedShowBackBtn{
                navigationItem.leftBarButtonItems = nil
            }else {
                navigationItem.leftBarButtonItems = [customLeftBackButtonItem()]
            }
        } else {
            navigationItem.leftBarButtonItems = [customLeftBackButtonItem(),  customCloseButtonItem()]
        }
    }
    
    func customLeftBackButtonItem() -> UIBarButtonItem {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 25.0, height: UIScreen.navigationBarHeight)
        btn.addTarget(self, action: #selector(whenBackBtnClicked), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "back_leftButton"), for: .normal)
        btn.contentHorizontalAlignment = .left
        return UIBarButtonItem(customView: btn)
    }
    
    func customCloseButtonItem() -> UIBarButtonItem {
        let closeBt = UIButton(type: .custom)
        closeBt.setTitle("关闭", for: .normal)
        closeBt.addTarget(self, action: #selector(whenCloseBtnClicked), for: .touchUpInside)
        closeBt.frame = CGRect(x: 0, y: 0, width: 35.0, height: 30.0)
        closeBt.setTitleColor(UIColor.black, for: .normal)
        closeBt.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        let closeItem = UIBarButtonItem(customView: closeBt)
        return closeItem
    }
    
    @objc func whenBackBtnClicked() {
        if webView.canGoBack() {
            webView.goBack()
        }else {
            whenCloseBtnClicked()
        }
    }
    
    @objc func whenCloseBtnClicked() {
        if self.presentingViewController != nil {
            navigationController?.dismiss(animated: true, completion: nil)
        }else if navigationController?.topViewController == self && navigationController?.viewControllers.count != 1 {
            navigationController?.popViewController(animated: true)
        }else {
            if webView.wkWebView.backForwardList.backList.count >= 1 {
                webView.wkWebView.go(to: webView.wkWebView.backForwardList.backList.first!)
            }
        }
    }
}

extension PAWebViewController:PAWebViewDelegate {
    func webView(_ webView:PAWebView,didChangeTitle title:String?) {
        setWebView(title: title, level: .document)
    }
    
    func webView(_ webView:PAWebView,didChangeURL url:URL?) {
        
    }
    
    func webViewDidGoBackChange(_ webView: PAWebView, didChangeBackFlag: Bool) {
        operatorLeftBtns(needShow: didChangeBackFlag)
    }
    
    func webViewDidStartLoad(for webView:PAWebView) {
        startProgress()
    }
    
    func webViewDidFinishLoad(for webView:PAWebView) {
        finishProgress()
    }
    
    func webViewDidFailLoad(_ webView:PAWebView,error:Error) {
        finishProgress()
    }
    
    func webViewShouldStartLoad(_ webView:PAWebView,request:URLRequest)->Bool {
        if let requestString = request.url?.absoluteString {
            return executeJSBridge(requestString: requestString)
        }
        return true
    }
    
    func webView(_ webView:PAWebView,messageName:String,body:Any) {
        dealUserContentController(messageName: messageName, body: body)
    }
}

extension PAWebViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
