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
    let documentService = DocumentServiceMock()
    
    override func setUp() {
        super.setUp()
        resultsViewModel = ResultsViewModel(documentService: documentService)
    }
    
    func testInitialization() {
        XCTAssertNotNil(resultsViewModel.documentService, "document service should no tbe nil after initialization")
        XCTAssertEqual("test value", resultsViewModel.sections[0].items[0].value,
                       "the first item in the main section should match the one declared in the document service mock")
        XCTAssertEqual(resultsViewModel.sections[0].items.count, 1,
                       "there should be only one item in the first section")
        XCTAssertEqual(resultsViewModel.sections.count, 2,
                       "there should be 2 sections, since there are main and other parameters")
    }
    
    func testUpdatedAnalysisResults() {
        resultsViewModel.sections[0].items[0].value = "Modified value"
        let modifiedAnalysisResults = resultsViewModel.updatedAnalysisResults
        
        XCTAssertEqual("Modified value", modifiedAnalysisResults["main parameter 1"]?.value,
                       "the first item in the main section should match the one declared in the document service mock")
    }
    
    func testSendFeedback() {
        resultsViewModel.sendFeedBack()
        XCTAssertTrue(documentService.feedBackSent, "feedback should be sent when this method is called")
    }
}
