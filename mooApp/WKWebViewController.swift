//
//  WKWebView.swift
//  mooApp
//
//  Created by duy on 4/12/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import Foundation
import WebKit

// protocol used for sending data back
protocol WKWeViewDelegate: class {
    func checkAddNew(isAddNew: Bool)
}

class WKWebViewController: UIViewController, WKUIDelegate,WKNavigationDelegate {
    
    var webView: WKWebView!
    var url:URL?
    var loadCount: Int = 0
    var isAddNew: Bool = false
    weak var delegate: WKWeViewDelegate? = nil
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if url != nil{
            //let myURL = URL(string: url!)
            let myRequest = URLRequest(url: url!)
            webView.load(myRequest)
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      
        if let url = navigationAction.request.url?.absoluteString {
            if url.lowercased().range(of:"access_token") == nil && url != "about:blank"{
                self.loadCount += 1
                let myRequest = URLRequest(url: URL(string:SharedPreferencesService.sharedInstance.bindTokenAndLanggaueTo(url))!)
                webView.load(myRequest)
                decisionHandler(.cancel)
            }else{
                 decisionHandler(.allow)
            }
        }else{
             decisionHandler(.allow)
        }
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.loadCount > 1{
            self.isAddNew = true
        }
        delegate?.checkAddNew(isAddNew: self.isAddNew)
    }
}
