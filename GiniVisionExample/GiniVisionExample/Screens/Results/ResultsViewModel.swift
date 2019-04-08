//
//  ResultsViewModel.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import Gini

typealias ExtractionSections = [(title: String, items: [Extraction])]

protocol ResultsViewModelProtocol: class {
    
    var sections: ExtractionSections { get set }
    var documentAnalysisHelper: DocumentAnalysisHelper<DefaultDocumentService> { get }
    var updatedAnalysisResults: [Extraction] { get }
    var analysisResults: [Extraction] { get }
    
    func sendFeedBack()
    func updateExtraction(at indexPath: IndexPath, withValue value: String?)
    func parseSections(from results: [Extraction])
}

final class ResultsViewModel: ResultsViewModelProtocol {
    
    var sections: ExtractionSections = [("Main parameters", []), ("Rest", [])]
    var documentAnalysisHelper: DocumentAnalysisHelper<DefaultDocumentService>
    var analysisResults: [Extraction]
    var updatedAnalysisResults: [Extraction] {
        var currentAnalysisResults = analysisResults
        sections.forEach { section in
            section.items.forEach { item in
                if let index = currentAnalysisResults.firstIndex(where: { $0.name == item.name }) {
                    currentAnalysisResults[index] = item
                }
            }
        }
        return currentAnalysisResults
    }
    
    init(documentAnalysisHelper: DocumentAnalysisHelper<DefaultDocumentService> = .init(), results: [Extraction]) {
        self.documentAnalysisHelper = documentAnalysisHelper
        self.analysisResults = results
        self.parseSections(from: results)
    }
    
    func sendFeedBack() {
        documentAnalysisHelper.sendFeedback(with: updatedAnalysisResults)
    }
    
    func parseSections(from results: [Extraction]) {
        results.forEach { extraction in
            let section = documentAnalysisHelper.pay5Parameters.contains(extraction.name ?? "") ? 0 : 1
            sections[section].items.append(extraction)
        }
    }
    
    func updateExtraction(at indexPath: IndexPath, withValue value: String?) {
        guard let value = value else { return }
        let modifiedExtraction = sections[indexPath.section].items[indexPath.row]
        sections[indexPath.section].items[indexPath.row] = Extraction(box: modifiedExtraction.box,
                                                                      candidates: modifiedExtraction.candidates,
                                                                      entity: modifiedExtraction.entity,
                                                                      value: value,
                                                                      name: modifiedExtraction.name)
    }
}
