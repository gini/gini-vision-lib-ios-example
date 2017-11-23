//
//  AppCoordinatorTests.swift
//  GiniVisionExampleTests
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample
@testable import Gini_iOS_SDK

final class AppCoordinatorTests: XCTestCase {
    
    var appCoordinator: AppCoordinator!
    
    override func setUp() {
        super.setUp()
        appCoordinator = AppCoordinator(window: UIWindow(frame: UIScreen.main.bounds))
    }
    
    func testInitialization() {
        XCTAssertEqual(appCoordinator.childCoordinators.count, 0,
                       "child coordinators array should be empty after initialization")
        XCTAssertNotNil(appCoordinator.window, "window should not be nil after after initialization")
    }
    
    func testWindowRootViewControllerAfterStart() {
        appCoordinator.start()
        XCTAssertNotNil(appCoordinator.window.rootViewController,
                        "window should have a rootviewcontroller after starting app")
    }
    
    func testMainViewControllerDelegateAfterStart() {
        appCoordinator.start()
        XCTAssertNotNil(appCoordinator.mainViewController.delegate as? AppCoordinator)
    }
    
    // TODO: Move to screen api coordinator tests when implemented
    func testResultsViewControllerDelegate() {
        let result: [String: GINIExtraction] = ["first extraction": GINIExtraction(name: "name", value: "value", entity: "entity", box: [:])!]
        let resultsViewController = appCoordinator.showResultsViewController(withResult: result)
        XCTAssertNotNil(resultsViewController.delegate as? AppCoordinator,
                       "resultsViewController delegate should be an instance of AppCoordinator")
    }
    
}
