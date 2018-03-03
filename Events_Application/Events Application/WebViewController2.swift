//
//  WebViewController2.swift
//  Events Application
//
//  Created by Kristian Curcic on 08/01/2018.
//  Copyright © 2018 Kristian Curcic. All rights reserved.
//

import UIKit
import WebKit

class WebViewController2: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var newURL: String = ""
    
    override func loadView() {
        
        // Loads web browser into view controller        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(newURL)")
        
        let myURL = URL(string: "\((newURL))")
        
        // Loads event URL to make a URL request        
        let myRequest = URLRequest(url: myURL!)
        
        // Loads browser with URL request to fetch website
        webView.load(myRequest)
        
    }
    

}
