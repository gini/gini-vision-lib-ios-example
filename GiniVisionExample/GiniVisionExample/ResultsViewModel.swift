//
//  ResultsViewModel.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import Gini_iOS_SDK

typealias Results = (title: String, items: [(name: String, value: String, id: String)])

protocol ResultsViewModelProtocol: class {
    
    var sections: [Results] { get set }
    var documentService: DocumentServiceProtocol { get }
    var updatedAnalysisResults: AnalysisResults { get }
    
    init(documentService: DocumentServiceProtocol)
    func sendFeedBack()
    func parseSections(fromResults results: AnalysisResults)
}

final class ResultsViewModel: ResultsViewModelProtocol {

    var sections: [Results] = [("Main parameters", []), ("Rest", [])]
    var documentService: DocumentServiceProtocol
    var updatedAnalysisResults: AnalysisResults {
        var currentAnalysisResults = documentService.result
        sections.forEach { section in
            section.items.forEach { item in
                currentAnalysisResults[item.id]?.value = item.value
            }
        }
        return currentAnalysisResults
    }
    
    init(documentService: DocumentServiceProtocol = DocumentService()) {
        self.documentService = documentService
        parseSections(fromResults: self.documentService.result)
    }
    
    func sendFeedBack() {
        documentService.sendFeedback(withUpdatedResults: updatedAnalysisResults)
    }
    
    func parseSections(fromResults results: AnalysisResults) {
        results.keys.forEach { key in
            if documentService.pay5Parameters.contains(key) {
                if let result = results[key] {
                    sections[0].items.append((result.name, result.value, key))
                }
            }
        }
    }
}
