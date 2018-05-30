# WebViewApp
##功能
* 调用显示h5页面
* native与h5交互
*  长按识别 保存图片
* 调用打电话 发邮件功能

## 介绍：
###调用方式：
``` swift
 let controller = PAWebViewController(urlString: "https://www.baidu.com")
 controller.setWebView(title: "baidu.com", level: .document)
 navigationController.pushViewController(controller, animated: true)
```
PAWebViewController介绍：

```swift
 required init(urlString url:String?,allowsBackForwardNavigationGestures:Bool = true) 
```

 PAWebViewController初始化方法必传请求url，可选传allowsBackForwardNavigationGestures

配置navigation的title，可通过设置
```swift
func setWebView(title:String?, level:PAWebViewTitleLevel)
```

优先级：webHIgherTitle<-documentTitle<-title

通过调用func configScriptMessage()->(scriptMessages:[String]?,scriptSouces:[String]?)? 配置注入的js  和 添加与js交互的方法名称
js与native交互方式有2种：

+ 通过拦截请求url 获取url配带的信息，具体在 func executeJSBridge(requestString str:String)->Bool中添加逻辑
+ 通过configScriptMessage()->(scriptMessages:[String]?,scriptSouces:[String]?)? 配置与js交互的方法名称，通过func dealUserContentController(messageName:String,body:Any) 处理native逻辑

建议使用第二种方式去处理js与native的交互。

长按图片弹出保存图片识别图片，可按实际情况使用SDWebImage去下载处理

另外：清除缓存调用PACookieSyncManager.sharedInstance.clearCookie()


 
 

