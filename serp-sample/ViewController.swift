//
//  ViewController.swift
//  serp-sample
//
//  Created by Webcash on 2019/11/26.
//  Copyright © 2019 WebCash. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        
        webView = WKWebView(frame: self.view.frame)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        self.view = self.webView!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let lnk = "https://serpadmin.appplay.co.kr/pfmc_0001_00.act"
        let url = URL(string: lnk)
        let request = URLRequest(url: url!)
        
        
        webView.load(request) // 웹뷰 띄우기 //
        
    }


}

