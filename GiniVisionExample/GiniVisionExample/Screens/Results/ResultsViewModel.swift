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

final class ResultsViewModel {
    
    var sections: ExtractionSections = [("Main parameters", []), ("Rest", [])]
    var documentAnalysisHelper: DocumentAnalysisHelper
    var analysisResults: ExtractionResult
    var updatedExtractions: [Extraction] {
        var extractions = analysisResults.extractions
        sections.forEach { section in
            section.items.forEach { item in
                if let index = extractions.firstIndex(where: { $0.name == item.name }) {
                    extractions[index] = item
                }
            }
        }
        return extractions
    }
    
    init(documentAnalysisHelper: DocumentAnalysisHelper, results: ExtractionResult) {
        self.documentAnalysisHelper = documentAnalysisHelper
        self.analysisResults = results
        self.parseSections(from: results)
    }
    
    func sendFeedBack() {
        documentAnalysisHelper.sendFeedback(with: updatedExtractions)
    }
    
    func parseSections(from results: ExtractionResult) {
        results.extractions.forEach { extraction in
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
