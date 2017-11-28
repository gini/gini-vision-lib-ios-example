//
//  WebViewControllerTests.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/22/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample

class WebViewControllerTests: XCTestCase {
    
    let url = URL(string: "http://developer.gini.net/gini-vision-lib-ios/docs/changelog.html")
    lazy var webViewController = WebViewController(title: "TestTitle",
                                                   url: self.url!)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testViewControllerTitle() {
        _ = webViewController.view
        XCTAssertEqual("TestTitle", webViewController.title,
                       "view controller title should match with the one passed on the initializer")
    }
    
    func testCurrentURL() {
        _ = webViewController.view
        XCTAssertEqual("http://developer.gini.net/gini-vision-lib-ios/docs/changelog.html",
                       webViewController.url.absoluteString,
                       "view controller utl should match with the one passed on the initializer")
    }
    
    func testWebViewNavigationDelegate() {
        XCTAssertNotNil(webViewController.webView.navigationDelegate as? WebViewController,
                        "webView navigation delegate should be an instance of WebViewController")
    }
    
}
