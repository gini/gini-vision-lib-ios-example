//
//  ScreenAPICoordinatorTests.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/24/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample
@testable import GiniVision

final class ScreenAPICoordinatorTests: XCTestCase {
    
    var screenAPICoordinator: ScreenAPICoordinator!
    var documentService: DocumentServiceProtocol = DocumentServiceMock()
    var analysisScreenDelegateMock = AnalysisDelegateMock()
    
    func testInitialization() {
        screenAPICoordinator = ScreenAPICoordinator(importedDocument: nil, documentService: documentService)

        XCTAssertNotNil(screenAPICoordinator?.rootViewController, "the root view controller should never be nil")
        XCTAssertTrue(screenAPICoordinator?.childCoordinators.count == 0,
                      "there should not be child coordinators on initialization")
    }
    
    func testStartAnalyisWhenCapture() {
        screenAPICoordinator = ScreenAPICoordinator(importedDocument: nil, documentService: documentService)
        let image = urlFromImage(named: "invoice", fileExtension: "jpg")!
        let document = GiniVisionDocumentBuilder(data: try? Data(contentsOf: image), documentSource: .external).build()!
        screenAPICoordinator.didCapture(document: document)
        
        XCTAssertTrue(documentService.isAnalyzing, "documentService should start analyzing when did review")
    }
    
    func testNotAnalyzingWhenDidCancelReview() {
        screenAPICoordinator = ScreenAPICoordinator(importedDocument: nil, documentService: documentService)
        let image = urlFromImage(named: "invoice", fileExtension: "jpg")!
        let document = GiniVisionDocumentBuilder(data: try? Data(contentsOf: image), documentSource: .external).build()!
        screenAPICoordinator.didCapture(document: document)
        screenAPICoordinator.didCancelReview()
        
        XCTAssertFalse(documentService.isAnalyzing, "documentService should stop analyzing when did review")
        XCTAssertTrue(documentService.result.isEmpty, "documentService results should be nil when did cancel review")

    }
    
    func testNotAnalyzingWhenDidCancelAnalysis() {
        screenAPICoordinator = ScreenAPICoordinator(importedDocument: nil, documentService: documentService)
        let image = urlFromImage(named: "invoice", fileExtension: "jpg")!
        let document = GiniVisionDocumentBuilder(data: try? Data(contentsOf: image), documentSource: .external).build()!
        screenAPICoordinator.didReview(document: document, withChanges: false)
        screenAPICoordinator.didShowAnalysis(analysisScreenDelegateMock)
        screenAPICoordinator.didCancelAnalysis()
        
        XCTAssertFalse(documentService.isAnalyzing, "documentService should stop analyzing when did review")
        XCTAssertTrue(documentService.result.isEmpty, "documentService results should be nil when did cancel analysis")
        XCTAssertNotNil(screenAPICoordinator.screenAPIAnalysisScreenDelegate,
                     "dscreen API analysis screen delegate should be nil when did cancel analysis")

    }
    
    func testScreenAPIAnalysisScreenDelegateWhenShowAnalysis() {
        screenAPICoordinator = ScreenAPICoordinator(importedDocument: nil, documentService: documentService)
        screenAPICoordinator.didShowAnalysis(analysisScreenDelegateMock)
        
        XCTAssertNotNil(screenAPICoordinator.screenAPIAnalysisScreenDelegate,
                     "screen API analysis screen delegate should not be nil when did cancel analysis")
        
    }
    
    class AnalysisDelegateMock: AnalysisDelegate {
        func displayError(withMessage message: String?, andAction action: NoticeAction?) {
            
        }
        
        func tryDisplayNoResultsScreen() -> Bool {
            return true
        }
        
    }
    
}
