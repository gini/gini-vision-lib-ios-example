//
//  MainViewControllerTests.swift
//  GiniVisionExampleTests
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample

final class MainViewControllerTests: XCTestCase {
    
    var mainViewController: MainViewController!
    
    override func setUp() {
        super.setUp()
        mainViewController = MainViewController()
    }
    
    func testInitialization() {
        XCTAssertNotNil(mainViewController.view, "view should not be nil")
    }
    
    func testStatusBarStyle() {
        XCTAssertEqual(mainViewController.preferredStatusBarStyle, .lightContent, "status bar style should be light")
    }
}
