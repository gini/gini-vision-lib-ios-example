//
//  HelpCoordinatorTests.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/22/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample

final class HelpCoordinatorTests: XCTestCase {
    
    var helpCoordinator: HelpCoordinator = HelpCoordinator()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testHelpViewControllerDelegate() {
        XCTAssertNotNil(helpCoordinator.helpViewController.delegate as? HelpCoordinator,
                        "help view controller delegate should be an instance of HelpCoordinator")
    }
    
    func testRootViewControllerType() {
        XCTAssertNotNil(helpCoordinator.rootViewController as? ContainerNavigationController,
                        "the root view controller should be a navigation controller")
    }
    
    func testNavStackCountWhenSelectLoadURL() {
        let helpLink = (title: "TestTitle",
                        url: URL(string: "http://developer.gini.net/gini-vision-lib-ios/docs/changelog.html"))
        helpCoordinator.help(viewController: helpCoordinator.helpViewController, didSelectLink: helpLink)
        
        XCTAssertNotNil(helpCoordinator.webViewController,
                        "web view controller should not be nil after load it into navigation controller")
    }
}
