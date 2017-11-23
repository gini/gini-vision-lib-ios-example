//
//  ResultsViewModelTests.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample
@testable import Gini_iOS_SDK

final class ResultsViewModelTests: XCTestCase {

    var resultsViewModel: ResultsViewModel!
    let result: [String: GINIExtraction] = ["first extraction": GINIExtraction(name: "name",
                                                                               value: "value",
                                                                               entity: "entity",
                                                                               box: [:])!]
    
    override func setUp() {
        super.setUp()
        resultsViewModel = ResultsViewModel(result: result)
    }
    
    func testInitialization() {
        XCTAssertNotNil(resultsViewModel.documentService, "document service should no tbe nil after initialization")
    }
}
