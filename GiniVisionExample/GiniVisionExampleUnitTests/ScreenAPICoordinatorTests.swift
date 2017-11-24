//
//  ScreenAPICoordinatorTests.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/24/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample

final class ScreenAPICoordinatorTests: XCTestCase {
    
    var screenAPICoordinator: ScreenAPICoordinator!
    
    func testInitialization() {
        screenAPICoordinator = ScreenAPICoordinator(importedDocument: nil)
        
        XCTAssertNotNil(screenAPICoordinator?.rootViewController, "the root view controller should never be nil")
        XCTAssertTrue(screenAPICoordinator?.childCoordinators.count == 0,
                      "there should not be child coordinators on initialization")
    }
    
}
