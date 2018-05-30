# WebViewApp
## 功能
* 调用显示h5页面
* native与h5交互
*  长按识别 保存图片
* 调用打电话 发邮件功能

## 介绍：
### 调用方式：
``` swift
 let controller = PAWebViewController(urlString: "https://www.baidu.com")
 controller.setWebView(title: "baidu.com", level: .document)
 navigationController.pushViewController(controller, animated: true)
```
PAWebViewController介绍：

```swift
 required init(urlString url:String?,allowsBackForwardNavigationGestures:Bool = true,nativeUrl:Url? = nil) 
```

 PAWebViewController初始化方法必传请求url，可选传allowsBackForwardNavigationGestures 是否允许右滑页面返回 nativeUrl 本地资源地址

配置navigation的title，可通过设置
```swift
func setWebView(title:String?, level:PAWebViewTitleLevel)
```

优先级：webHIgherTitle<-documentTitle<-title

js与native交互方式有2种：

+ 通过拦截请求url 获取url配带的信息，具体在 func executeJSBridge(requestString str:String)->Bool中添加逻辑
+ 通过configScriptMessage()->(scriptMessages:[String]?,scriptSouces:[String]?)? 配置与js交互的方法名称和注入js代码，通过func dealUserContentController(messageName:String,body:Any) 处理native逻辑

建议使用第二种方式去处理js与native的交互。

长按图片弹出保存图片识别图片，可按实际情况使用SDWebImage去下载处理 具体后续逻辑请自行添加

**  提醒：**

由于调用add(_ scriptMessageHandler: WKScriptMessageHandler, name: String)方法，addScriptMessageHandler将会对scriptMessageHandler参数传入的对象做强引用,而控制器又强引用了webView,然后webView又强引用了configuration,configuration又强引用了WKUserContentController对象,所以导致了引用循环,从而导致控制器不被释放的问题，所以我在 
```swift
override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil{
            progressView.removeFromSuperview()
            webView.removeScriptMessages()
        }
    }
```
中打破引用环。


***
获取项目中js代码
```swift
 let jsPath = Bundle.main.path(forResource: "swiftJS", ofType: "js")
 let javascriptSource = try? String.init(contentsOfFile: jsPath!, encoding: String.Encoding.utf8)

```

 加载本地html
 ```swift 
  let url = Bundle.main.url(forResource: "swiftJS", withExtension: "html")
 webView.load(URLRequest.init(url: url!))
```
***


另外：清除缓存调用PACookieSyncManager.sharedInstance.clearCookie()


 
 

