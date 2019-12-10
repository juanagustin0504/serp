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
    
    var webView: WKCookieWebView! // 사용할 웹뷰 //
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let contentController = WKUserContentController() // js -> native 호출할 때 //
    let config = WKWebViewConfiguration()
    
    let loginURLStr: String = "https://serpadmin.appplay.co.kr/pfmc_0001_00.act"
    let mainURLStr: String = "https://serpadmin.appplay.co.kr/pfmc_0001_01.act"
    
    
    override func loadView() {
        super.loadView()
        
        // native -> js call (문서 시작시에만 가능한, 환경설정으로 사용함), source부분에 함수 대신 HTML직접 사용 가능 //
        //        let userScript = WKUserScript(source: "redHeader()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        //        contentController.addUserScript(userScript)
        
        // native -> js call (일반적인 함수 호출) //
        
        
        // js -> native call : name의 값을 지정하여, js에서 webkit.massageHandlers.NAME.postMessage("");와 연동되는 것, userContentController 함수에서 처리한다. //
//        contentController.add(self, name: "-")
//
//        config.userContentController = contentController
        
        let _frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let conf = WKWebViewConfiguration()
        conf.preferences = preferences
        
        self.webView = WKCookieWebView(frame: _frame, configuration: conf, useRedirectCookieHandling: true)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.allowsLinkPreview = false
        
        self.view.addSubview(webView) // == self.view = self.webView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url = URL(string: loginURLStr)
        let request = URLRequest(url: url!)
        
        _ = self.webView.load(request)
        
    }
    
    // javaScript Alert 처리 //
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // webAction Alert이 필요하다면 주석 해제. //
//        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//
//        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//
//        self.present(alertController, animated: true, completion: nil)
        if message.contains("아이디") || message.contains("비밀번호") {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alertController, animated: true, completion: nil)
        } else if message.lowercased().contains("iwebaction:") {
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
                        } // end of if "popup_webview"
                    } // end of for "actionCode"
                } else {
                    for actionCode in actionCodes {
                        if actionCode == "close_webview" {
                            print("close")
                            closeWebView()
                        } else if actionCode == "finish_app" {
                            finishApp()
                        }
                    } // end of for "actionCode"
                } // end of else "actionData"
            } // end of if "actionCode"
        } // end of if "message == iwebaction:"
        completionHandler()
        
    } // end of webView
    
    // WebView 안에서 링크 이동 감지 //
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 실행 안 됨 //

        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if url.host == "serpadmin.appplay.co.kr" {
        } else if url.host == "apis.openapi.sk.com" {
            // Tmap url 사파리로 이동 후 앱으로 이동 //

            UIApplication.shared.open(url, options: [:], completionHandler: {(action) in
//                self.webView.goBack()
            })
            self.webView.goBack()

        } else if url.host == "kakaonavi-wguide.kakao.com" {
            // 카카오내비 url 앱이 있으면 앱을 실행, 없다면 기존의 웹뷰에서 실행 //
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: {(action) in
                    self.webView.goBack()
                })
            }
        } else if url.absoluteString.lowercased().contains("tmap://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if url.host == "itunes.apple.com" {
            let tmapStr = "tmap://"
            if let tmapURL = URL(string: tmapStr) {
                if !UIApplication.shared.canOpenURL(tmapURL) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        
        } else {
            print(url)
        }
        decisionHandler(.allow)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { webView.reload() }
    
    func goToMain() {_ = self.webView.load(URLRequest(url: URL(string: mainURLStr)!))}

    
    func popupWebViewByGet(lnk: String) {
//        https://serpadmin.appplay.co.kr/pfmc_0001_00.act/
        // get 방식으로 호출 //
        let url = URL(string: loginURLStr + "/" + lnk) // 기존 링크 + js message 링크 //
        let request = URLRequest(url: url!)
        _ = self.webView.load(request)
    }
    
    func popupWebViewByPost(lnk: String, actionData: [String:Any]) {
        
        guard let url = URL(string: loginURLStr) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = "_url=\(String(describing: actionData["_url"]))".data(using: .utf8, allowLossyConversion: false)
        request.httpBody = body
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let res = response {
                print(res)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    // popup_webview 닫기
    func closeWebView() {
        if self.webView.canGoBack {
            self.webView.goBack()
        } else {
            goToMain()
        }
    }
    
    // finish app //
    func finishApp() { exit(0) }
    
    // js -> native call //
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "iWebAction" {
            print("iWebAction")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
