//
//  SearchDetailViewController.swift
//  mooApp
//
//  Created by duy on 1/15/16.
//  Copyright © 2016 moosocialloft. All rights reserved.
//

import Foundation
import UIKit

class SearchDetailViewController: AppViewController,UIWebViewDelegate{
   
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var webUrl:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        self.navigationController?.navigationBar.tintColor = AppConfigService.sharedInstance.config.navigationBar_textTintColor
         self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppConfigService.sharedInstance.config.navigationBar_textTintColor]
        if webUrl != nil {
            if let encodedString = webUrl!.addingPercentEncoding(
                withAllowedCharacters: CharacterSet.urlFragmentAllowed),
                let url = URL(string: encodedString) {
                webView.loadRequest(URLRequest(url:url));
            }
            //webView.loadRequest(NSURLRequest(URL:NSURL(string:webUrl!)!))
        }
        loadingIndicator.color = AppConfigService.sharedInstance.config.color_main_style
    }
    // Mark: Webview behavior
    internal func webViewDidStartLoad(_ webView: UIWebView) {
        
        loadingIndicator.startAnimating()
          UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    internal func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingIndicator.stopAnimating()
         UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.title = webView.stringByEvaluatingJavaScript(from: "document.title")
    }
    internal func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //NSLog("didFail: %@; stillLoading: %@", webView.request!.URL!,(webView.loading ? "YES": "NO"));
        loadingIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
