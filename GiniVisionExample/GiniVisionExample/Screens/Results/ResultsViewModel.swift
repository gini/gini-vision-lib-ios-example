//
//  ResultsViewModel.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import Gini_iOS_SDK

typealias ExtractionCollection = [(title: String, items: [Extraction])]

protocol ResultsViewModelProtocol: class {
    
    var extractions: ExtractionCollection { get set }
    var documentService: DocumentServiceProtocol { get }
    var updatedAnalysisResults: AnalysisResults { get }
    var analysisResults: AnalysisResults { get }
    
    init(documentService: DocumentServiceProtocol, results: AnalysisResults)
    func sendFeedBack()
    func updateExtraction(at indexPath: IndexPath, withValue value: String?)
    func parseSections(from results: AnalysisResults)
}

final class ResultsViewModel: ResultsViewModelProtocol {
    
    var extractions: ExtractionCollection = [("Main parameters", []), ("Rest", [])]
    var documentService: DocumentServiceProtocol
    var analysisResults: AnalysisResults
    var updatedAnalysisResults: AnalysisResults {
        var currentAnalysisResults = analysisResults
        extractions.forEach { section in
            section.items.forEach { item in
                currentAnalysisResults[item.key]?.value = item.value
            }
        }
        return currentAnalysisResults
    }
    
    init(documentService: DocumentServiceProtocol = DocumentService(), results: AnalysisResults) {
        self.documentService = documentService
        self.analysisResults = results
        self.parseSections(from: results)
    }
    
    func sendFeedBack() {
        documentService.sendFeedback(with: updatedAnalysisResults)
    }
    
    func parseSections(from results: AnalysisResults) {
        results.keys.forEach { key in
            if let result = results[key] {
                let extraction = Extraction(giniExtraction: result)
                let section = documentService.pay5Parameters.contains(extraction.key) ? 0 : 1
                extractions[section].items.append(extraction)
            }
        }
    }
    
    func updateExtraction(at indexPath: IndexPath, withValue value: String?) {
        extractions[indexPath.section].items[indexPath.row].value = value ?? ""
    }
}
