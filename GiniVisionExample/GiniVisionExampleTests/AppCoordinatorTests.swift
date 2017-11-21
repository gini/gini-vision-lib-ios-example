//
//  AppCoordinatorTests.swift
//  GiniVisionExampleTests
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample

final class AppCoordinatorTests: XCTestCase {
    
    var appCoordinator: AppCoordinator!
    
    override func setUp() {
        super.setUp()
        appCoordinator = AppCoordinator(window: UIWindow(frame: UIScreen.main.bounds))
    }
    
    func testInitialization() {
        XCTAssertEqual(appCoordinator.childCoordinators.count, 0, "child coordinators array should be empty after initialization")
        XCTAssertNotNil(appCoordinator.window, "window should not be nil after after initialization")
    }
    
    func testWindowRootViewControllerOnStart() {
        appCoordinator.start()
        XCTAssertNotNil(appCoordinator.window.rootViewController, "window should have a rootviewcontroller after starting app")
    }
    
}
