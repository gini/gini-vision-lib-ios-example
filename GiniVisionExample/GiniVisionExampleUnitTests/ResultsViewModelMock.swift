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
    
    var extractions: ExtractionCollection = [("Section 0", [Extraction(key: "item 1", name: "value 1", value: "id 1"),
                                                        Extraction(key: "item 2", name: "value 2", value: "id 2")])]
    var documentService: DocumentServiceProtocol
    var feedBackSent: Bool = false
    var updatedAnalysisResults: AnalysisResults {
        return documentService.result ?? [:]
    }

    init(documentService: DocumentServiceProtocol = DocumentServiceMock()) {
        self.documentService = documentService
    }
    
    func sendFeedBack() {
        feedBackSent = true
    }
    
    func parseSections(fromResults results: AnalysisResults) {
        
    }
    
    func updateExtraction(at indexPath: IndexPath, withValue value: String?) {
        extractions[indexPath.section].items[indexPath.row].value = value ?? ""
    }
    
}
