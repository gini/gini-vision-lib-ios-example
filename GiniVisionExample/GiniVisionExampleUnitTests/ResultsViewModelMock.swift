//
//  ResultsViewModelMock.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
@testable import GiniVisionExample
@testable import Gini_iOS_SDK

final class ResultsViewModelMock: ResultsViewModelProtocol {
    
    var sections: [Results] = [("Section 0", [("item 1", "value 1", "id 1"), ("item 2", "value 2", "id 2")])]
    var documentService: DocumentServiceProtocol
    var feedBackSent: Bool = false
    var updatedAnalysisResults: AnalysisResults {
        return documentService.result
    }

    init(documentService: DocumentServiceProtocol = DocumentServiceMock()) {
        self.documentService = documentService
    }
    
    func sendFeedBack() {
        feedBackSent = true
    }
    
    func parseSections(fromResults results: AnalysisResults) {
        
    }
    
}
