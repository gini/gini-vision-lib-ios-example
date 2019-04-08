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
    
    var extractions: ExtractionSections = [("Section 0", [Extraction(key: "item 1", name: "value 1", value: "id 1"),
                                                        Extraction(key: "item 2", name: "value 2", value: "id 2")])]
    var documentService: DocumentServiceProtocol
    var feedBackSent: Bool = false
    var updatedAnalysisResults: AnalysisResults {
        return analysisResults
    }
    var analysisResults: AnalysisResults

    init(documentService: DocumentServiceProtocol, results: AnalysisResults) {
        self.documentService = documentService
        self.analysisResults = results
    }
    
    func sendFeedBack() {
        feedBackSent = true
    }
    
    func parseSections(from results: AnalysisResults) {
        
    }
    
    func updateExtraction(at indexPath: IndexPath, withValue value: String?) {
        extractions[indexPath.section].items[indexPath.row].value = value ?? ""
    }
    
}
