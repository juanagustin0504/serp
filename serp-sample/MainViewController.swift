//
//  ViewController.swift
//  serp-sample
//
//  Created by Webcash on 2019/11/28.
//  Copyright © 2019 WebCash. All rights reserved.
//

import UIKit
import WebKit

struct Person: Codable {
    var name: String
    var age: Int
}

struct iWebViewAction: Codable {
    var _action_code: String
    var _url: String
    var _type: String
}

class MainViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    
    @IBOutlet weak var containerView: UIView!
    
    var webView: WKWebView!
    var popupView: WKWebView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let contentController = WKUserContentController()
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
        let url = URL(string: lnk)
        let request = URLRequest(url: url!)
        
        
        
        webView.load(request) // 웹뷰 띄우기 //
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        print(message)

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
        // JavaScript Alert으로 전송되는 값 읽어서 iWebAction: 이후 부터 값을 읽어온 다음 처리 //
        // {
        //      "_action_code":"popup_webview",
        //      "_action_data":{
        //      "_url":"test_pfmc.act?LAST_LOGIN_DT=20191128&USE_INIT_ID=UTLZ_1711101710714...",
        //      "_type":"get"
        // }
        
//        let tmp = message.components(separatedBy: [" ", "\"", ":", "{", "}"])
//
//        print(tmp)
        
        
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//        let moon = Person(name: "Moon", age: 19)
//        let jsonData = try? encoder.encode(moon)
//
//        if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
//            print(jsonString)
//
//            let decoder = JSONDecoder()
//            let data = jsonString.data(using: .utf8)
//            if let data = data, let myPerson = try? decoder.decode(Person.self, from: data) {
//                print(myPerson.name)
//                print(myPerson.age)
//            }
//        }
        
//        let encoder = JSONEncoder()
//        let test = iWebViewAction(_action_code: "popup_webview", _url: "test_pfmc.act?LAST_LOGIN_DT=20191129&USE_INTT_ID=UTLZ_1711131611099&USE_INTT_NM=%EA%B4%80%EC%84%B8%EB%B2%95%EC%9D%B8%EB%8D%94%EB%B8%94%EC%9C%A0&ADDR=%EC%84%9C%EC%9A%B8%EC%8B%9C%20%EA%B0%95%EB%82%A8%EA%B5%AC%20%EC%96%B8%EC%A3%BC%EB%A1%9C%20714&DTL_ADDR=&ZPCD=&BIZ_NO=&SUMR_YM=2019%EB%85%84%2010%EC%9B%94&LOGN_PCNT_01=21&LOGN_PCNT_02=51&LOGN_PCNT_03=0&SALE_PCNT_01=0&SALE_PCNT_02=0&TRNS_PCNT_01=0&TRNS_PCNT_02=125&TRNS_PCNT_03=0&CTNT_PCNT_01=0&CTNT_PCNT_02=86&CTNT_PCNT_03=0&CTNT_PCNT_04=0&SMRT_PCNT_01=0&SMRT_PCNT_02=0&SMRT_PCNT_03=0&SMRT_PCNT_04=0&SMRT_PCNT_05=0&SMRT_PCNT_06=0&SMRT_PCNT_07=0&RPRT_PCNT_01=0&RPRT_PCNT_02=0&RPRT_PCNT_03=0", _type: "get")
//        let jsonData = try? encoder.encode(test)
//
//        if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
//            print(jsonString)
//
//            let decoder = JSONDecoder()
//            let data = jsonString.data(using: .utf8)
//            if let data = data, let iMessage = try? decoder.decode(iWebViewAction.self, from: data) {
//                print(iMessage._action_code)
//
//                print(iMessage._url)
//                print(iMessage._type)
//
//            }
//        }
        
        // 분리완료 //
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
                            popupWebview(lnk: (actionData["_url"] as? String)!)
                        }
//                        print(actionCode)
                        print(actionData["_url"]!)
                        print(actionData["_type"]!)
                        
                    }
                } else {
                    for actionCode in actionCodes {
                        if actionCode == "close_webview" {
                            closeWebview()
                        }
                        print(actionCode)
                    }
                }
            }
        }
        
    }
    
    func popupWebview(lnk: String) {
        
        
        
        contentController.add(self, name: "close_webview")
        
        config.userContentController = contentController
        
        popupView = WKWebView(frame: self.view.frame, configuration: config)
        popupView.uiDelegate = self
        popupView.navigationDelegate = self
        
//        self.view.addSubview(popupView)
        
        let url = URL(string: "https://serpadmin.appplay.co.kr/pfmc_0001_00.act/" + lnk)
        let request = URLRequest(url: url!)
        webView.load(request)
        
//        popupView.load(request)
    }

    func closeWebview() {
        print("closeWebview()")
//        popupView.isHidden = true
        if webView.canGoBack {

            webView.goBack()
        }
//        popupView.evaluateJavaScript("close_webview()", completionHandler: {(result, error) in
//
//            if self.popupView.canGoBack {
//
//                self.popupView.goBack()
//            }
//            print(error)
//        })
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
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
        if message.name == "close_webview" {
            print(message.body)
            abc()
        }
    }
    
    func abc() {
        print("abc call")
    }
    
//    fileprivate func checkActionCode(jsongData:String,completion: @escaping (String,[String:Any]?) -> Void) {
//        if jsongData.lowercased().contains("iwebaction:") {
//            var actionDic: [String: Any]?
//            actionDic = String(jsongData.dropFirst(11)).toDictionary()
//            if let actionDic = actionDic {
//                guard let actionCodes = (actionDic["_action_code"] as? String)?.components(separatedBy: "|") else {
//                    return
//                }
//                if let actionData = actionDic["_action_data"] as? [String:Any] {
//                    for actionCode in actionCodes {
//                        completion(actionCode,actionData)
//                    }
//                }else {
//                    for actionCode in actionCodes {
//                        completion(actionCode,nil)
//                    }
//                }
//            }
//        }
//    }
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
