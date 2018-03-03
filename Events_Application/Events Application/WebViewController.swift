//
//  WebViewController.swift
//  Events Application
//
//  Created by Kristian Curcic on 14/12/2017.
//  Copyright © 2017 Kristian Curcic. All rights reserved.
//

import UIKit
import WebKit
class WebViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var recievedEvent:Event?
    
    override func loadView() {
        
        // Loads web browser into view controller
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prints event URL to console
        print("\(recievedEvent?.url)")
        
        let myURL = URL(string: "\((recievedEvent?.url)!)")
        
        // Loads event URL to make a URL request
        let myRequest = URLRequest(url: myURL!)
        
        // Loads browser with URL request to fetch website
        webView.load(myRequest)
    }
}

