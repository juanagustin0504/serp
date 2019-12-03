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
        } else if url.host == "apis.openapi.sk.com" {
            // Tmap 버튼을 누르면 기존에 열려있는 popup뷰가 한번 더 열리고 Tmap 화면이 떠 있음. //
            // 그래서 Tmap 버튼을 누르고 닫기를 2번 해야 함. //
            /* Tmap url
             https://apis.openapi.sk.com/tmap/app/routes?appKey=139a893c-dcdd-43a1-8661-c4ae8f201c08&name=%EA%B0%91%EC%9D%84%EA%B7%B8%EB%A0%88%EC%9D%B4%ED%8A%B8%EB%B0%B8%EB%A6%AC&lon=126.88751109358344&lat=37.47951408984022
             https://www.tmap.co.kr/tmap2/mobile/route.jsp?appKey=139a893c-dcdd-43a1-8661-c4ae8f201c08&name=%EA%B0%91%EC%9D%84%EA%B7%B8%EB%A0%88%EC%9D%B4%ED%8A%B8%EB%B0%B8%EB%A6%AC&lon=126.88751109358344&lat=37.47951408984022
             tmap://?rGoName=%EA%B0%91%EC%9D%84%EA%B7%B8%EB%A0%88%EC%9D%B4%ED%8A%B8%EB%B0%B8%EB%A6%AC&rGoX=126.88751109358344&rGoY=37.47951408984022
             */
            print("tmap")
            UIApplication.shared.open(url, options: [:], completionHandler: {(action) in
                self.webView.goBack()
                
            })
            self.webView.goBack()
            
        } else if url.host == "kakaonavi-wguide.kakao.com" {
            /* 카카오내비 url 사파리로 띄우는 것이 아닌 앱 실행
              https://kakaonavi-wguide.kakao.com/openapi/?appkey=d3bd1dcd0054d2d8ce86f75337ce4d7e&apiver=1.0&extras=%7B%22KA%22%3A%22sdk%2F1.35.3%20os%2Fjavascript%20lang%2Fen-US%20device%2FiPhone%20origin%2Fhttps%253A%252F%252Fserpadmin.appplay.co.kr%22%7D&param=%7B%22destination%22%3A%7B%22name%22%3A%22%EC%84%9C%EC%9A%B8%20%EA%B8%88%EC%B2%9C%EA%B5%AC%20%EB%94%94%EC%A7%80%ED%84%B8%EB%A1%9C9%EA%B8%B8%2032%22%2C%22x%22%3A126.88751109358344%2C%22y%22%3A37.47951408984022%7D%2C%22option%22%3A%7B%22coord_type%22%3A%22wgs84%22%7D%7D
            */
            print("kakaonavi")
            UIApplication.shared.open(url, options: [:], completionHandler: {(action) in
                self.webView.goBack()
                
            })
        } else {
            print(url)
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
