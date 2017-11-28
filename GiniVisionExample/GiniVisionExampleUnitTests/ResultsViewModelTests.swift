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
    
    func testInitializationAndParsing() {
        XCTAssertNotNil(resultsViewModel.documentService, "document service should no tbe nil after initialization")
        XCTAssertEqual("test value", resultsViewModel.extractions[0].items[0].value,
                       "the first item in the main section should match the one declared in the document service mock")
        XCTAssertEqual(resultsViewModel.extractions[0].items.count, 1,
                       "there should be only one item in the first section")
        XCTAssertEqual(resultsViewModel.extractions.count, 2,
                       "there should be 2 sections, since there are main and other parameters")
    }
    
    func testUpdatedAnalysisResults() {
        resultsViewModel.extractions[0].items[0].value = "Modified value"
        let modifiedAnalysisResults = resultsViewModel.updatedAnalysisResults
        
        XCTAssertEqual("Modified value", modifiedAnalysisResults["main 1"]?.value,
                       "the first item in the main section should match the one declared in the document service mock")
    }
    
    func testSendFeedback() {
        resultsViewModel.sendFeedBack()
        XCTAssertTrue(documentService.feedBackSent, "feedback should be sent when this method is called")
    }
    
    func testUpdatedValue() {
        let indexPath = IndexPath(row: 0, section: 0)
        let value = resultsViewModel.extractions[indexPath.section].items[indexPath.row].value
        
        resultsViewModel.updateExtraction(at: indexPath, withValue: "new value")
        let newValue = resultsViewModel.extractions[indexPath.section].items[indexPath.row].value
        XCTAssertNotEqual(value, newValue,
                       "the section item should have been modified when it was updated from the view")
    }
}
