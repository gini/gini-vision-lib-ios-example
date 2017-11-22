//
//  WebViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/22/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    var url: URL
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.load(URLRequest(url: self.url))
        return webView
    }()
    
    init(title: String, url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.title = title

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(webView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.frame
    }
}

// MARK: WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let nextUrl = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        let actionPolicy: WKNavigationActionPolicy = (nextUrl.absoluteString == url.absoluteString) ? .allow : .cancel
        decisionHandler(actionPolicy)
    }
}
