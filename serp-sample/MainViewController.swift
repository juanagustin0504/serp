//
//  ViewController.swift
//  serp-sample
//
//  Created by Webcash on 2019/11/28.
//  Copyright © 2019 WebCash. All rights reserved.
//

import UIKit
import WebKit

class MainViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView! // 사용할 웹뷰 //
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let contentController = WKUserContentController() // js -> native 호출할 때
    let config = WKWebViewConfiguration()
    
    override func loadView() {
        super.loadView()
        
        // native -> js call (문서 시작시에만 가능한, 환경설정으로 사용함), source부분에 함수 대신 HTML직접 사용 가능 //
        //        let userScript = WKUserScript(source: "redHeader()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        //        contentController.addUserScript(userScript)
        
        // native -> js call (일반적인 함수 호출)
        
        
        // js -> native call : name의 값을 지정하여, js에서 webkit.massageHandlers.NAME.postMessage("");와 연동되는 것, userContentController 함수에서 처리한다. //
        contentController.add(self, name: "iWebAction")
        
        config.userContentController = contentController
        
        
        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        
        //        self.view = self.webView!
        self.view.addSubview(webView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let lnk = "https://serpadmin.appplay.co.kr/pfmc_0001_00.act"
        let url = URL(string: lnk)
        let request = URLRequest(url: url!)
        
        webView.load(request) // 웹뷰 띄우기 //
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
        if message.lowercased().contains("iwebaction:") {
            var actionDic: [String: Any]?
            actionDic = String(message.dropFirst(11)).toDictionary()
            if let actionDic = actionDic {
                guard let actionCodes = (actionDic["_action_code"] as? String)?.components(separatedBy: "|") else {
                    return
                }
                
                if let actionData = actionDic["_action_data"] as? [String:Any] {
                    for actionCode in actionCodes {
                        if actionCode == "popup_webview" {
                            let lnk = (actionData["_url"] as? String)!
                            let type = actionData["_type"] as! String
                            if type.elementsEqual("get") {
                                // get 처리
                                popupWebViewByGet(lnk: lnk)
                            } else {
                                // post 처리
                                popupWebViewByPost(lnk: lnk, actionData: actionData)
                            }
                            
                        }
                        
                    }
                } else {
                    for actionCode in actionCodes {
                        if actionCode == "close_webview" {
                            closeWebview()
                        } // end of if "actionCode"
                    } // end of for "actionCode"
                } // end of else "actionData"
            } // end of if "actionCode"
        } // end of if "message == iwebaction:"
        
    } // end of webView
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 실행 안 됨 //

        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if url.host == "serpadmin.appplay.co.kr" {
            print("serp")
        } else {
            print("another")
            self.webView.goBack()
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
        decisionHandler(.allow)
    }
    
    func popupWebViewByGet(lnk: String) {
        
        // get 방식으로 호출 //
        let url = URL(string: "https://serpadmin.appplay.co.kr/pfmc_0001_00.act/" + lnk) // 기존 링크 + js message 링크 //
        let request = URLRequest(url: url!)
        self.webView.load(request)
        
    }
    
    func popupWebViewByPost(lnk: String, actionData: [String:Any]) {
        
        // post 방식으로 호출 //
        print("POST")
//        print(actionData)
//
//        let urlStr = "https://serpadmin.appplay.co.kr/pfmc_0001_00.act/" + lnk
//        let url = URL(string: urlStr)
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        request.value(forHTTPHeaderField: "Content-Type")
//
//        let body = urlStr.data(using: .utf8, allowLossyConversion: false)
//
//        request.httpBody = body
//
//        let session = URLSession.shared
//        session.dataTask(with: request) {(data, response, error) in
//            if let res = response {
//                print(res)
//            }
//
//            if let data = data {
//                do {
//
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
//                } catch {
//                    print(error)
//                }
//            }
//        }.resume()
    }
    
    func closeWebview() {
        // popup된 webview 닫기
        if webView.canGoBack {
            
            webView.goBack()
        }
    }
    
    
    // js -> native call
    @available(iOS 8.0, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "iWebAction" {
            print("iWebAction")
        }
    }
    
}


extension String {
    func toDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
