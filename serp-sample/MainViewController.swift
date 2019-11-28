//
//  ViewController.swift
//  serp-sample
//
//  Created by Webcash on 2019/11/28.
//  Copyright © 2019 WebCash. All rights reserved.
//

import UIKit
import WebKit

struct Test: Codable {
    var _action_code: String
    var _action_data: Dictionary<String, String>
}

class MainViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    
    @IBOutlet weak var containerView: UIView!
    
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func loadView() {
        super.loadView()
        
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        
        // native -> js call (문서 시작시에만 가능한, 환경설정으로 사용함), source부분에 함수 대신 HTML직접 사용 가능 //
//        let userScript = WKUserScript(source: "redHeader()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//        contentController.addUserScript(userScript)
        
        // native -> js call (일반적인 함수 호출)
        
        
        // js -> native call : name의 값을 지정하여, js에서 webkit.massageHandlers.NAME.postMessage("");와 연동되는 것, userContentController 함수에서 처리한다. //
        contentController.add(self, name: "iWebAction")
        
        config.userContentController = contentController
        
        
        webView = WKWebView(frame: self.containerView.frame, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        //        self.view = self.webView!
        self.view.addSubview(webView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let lnk = "https://serpadmin.appplay.co.kr/pfmc_0001_00.act"
        
        //        let lnk = "file:///Users/webcash/Assignment/serp-sample/serp-sample/test.html"
        let url = URL(string: lnk)
        let request = URLRequest(url: url!)
        
        
        webView.load(request) // 웹뷰 띄우기 //
        
    }
    
    //        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
    //            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    //            let otherAction = UIAlertAction(title: "OK", style: .default, handler: {action in completionHandler()})
    //            alert.addAction(otherAction)
    //
    //            self.present(alert, animated: true, completion: nil)
    //
    //        }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("!")
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        print(message)

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        let decoder = JSONDecoder()
        let data = message.data(using: .utf8)
        if let data = data, let myWebAction = try? decoder.decode(Test.self, from: data) {
            print(myWebAction._action_code)
            print(myWebAction._action_data)
            
        }
        
        self.present(alertController, animated: true, completion: nil)
        
        // JavaScript Alert으로 전송되는 값 읽어서 iWebAction: 이후 부터 값을 읽어온 다음 처리 //
        // {
        //      "_action_code":"popup_webview",
        //      "_action_data":{
        //      "_url":"test_pfmc.act?LAST_LOGIN_DT=20191128&USE_INIT_ID=UTLZ_1711101710714...",
        //      "_type":"get"
        // }
        
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("@")
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print("#")
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
            completionHandler(nil)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // js -> native call
    @available(iOS 8.0, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("!@#!@#!@#!@#!@#!@#")
        if message.name == "iWebAction" {
            print(message.body)
            abc()
        }
    }
    
    func abc() {
        print("abc call")
    }
    
}
