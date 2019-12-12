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
    
    private lazy var url = URL(string: "https://serpadmin.appplay.co.kr/pfmc_0001_00.act")!
    private let mainURLStr: String = "https://serpadmin.appplay.co.kr/pfmc_0001_01.act"
    
    var webView: WKWebView!
    
    private var httpCookieStore: WKHTTPCookieStore  {
        return WKWebsiteDataStore.default().httpCookieStore
    }
    
    func getCookies() {
        let cookiesStorage = HTTPCookieStorage.shared
        let userDefaults = UserDefaults.standard
        if let cookieDictionary = userDefaults.dictionary(forKey: "WebCookiesSaved") {
            for (_, cookieProperties) in cookieDictionary {
                if let cookie = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any] ) {
                    cookiesStorage.setCookie(cookie)
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
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
        let request = URLRequest(url: url)

        getCookies()
        
        _ = self.webView.load(request)

    }
    
    // javaScript Alert 처리 //
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
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

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self.webView.goBack()

        } else if url.host == "kakaonavi-wguide.kakao.com" {
            // 카카오내비 url 앱이 있으면 앱을 실행, 없다면 웹뷰에서 실행 //
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url {
            webView.saveCookies(for: url.host) { data in
                print("=========================================")
                print("\(url.absoluteString)")
                print(data)
            }
        }
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { webView.reload() }
    
    func goToMain() {_ = self.webView.load(URLRequest(url: URL(string: mainURLStr)!))}

    func popupWebViewByGet(lnk: String) {
//        https://serpadmin.appplay.co.kr/pfmc_0001_00.act/
        // get 방식으로 호출 //
        let url = URL(string: self.url.absoluteString + "/" + lnk) // 기존 링크 + js message 링크 //
        let request = URLRequest(url: url!)
        self.webView?.load(request)
    }
    
    func popupWebViewByPost(lnk: String, actionData: [String:Any]) {
        
        guard let url = URL(string: self.url.absoluteString) else {return}
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
        goToMain()
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

extension WKWebView {

    func load(urlString: String) {
        if let url = URL(string: urlString) { load(url: url) }
    }

    func load(url: URL) { load(URLRequest(url: url)) }
    
    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }
    
    func saveCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { (cookies) in
            
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            UserDefaults.standard.set(cookieDict, forKey: "WebCookiesSaved")
            UserDefaults.standard.synchronize()
            completion(cookieDict)
        }
    }
}
