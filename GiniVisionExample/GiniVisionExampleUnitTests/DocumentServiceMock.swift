//
//  DocumentServiceMock.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
@testable import GiniVisionExample
@testable import GiniVision
@testable import Gini_iOS_SDK

final class DocumentServiceMock: DocumentServiceProtocol {
    
    var compositeDocument: GINIDocument?
    var analysisCancellationToken: BFCancellationTokenSource?
    
    var isAnalyzing: Bool = false
    var hasExtractions: Bool {
        return result.filter { pay5Parameters.contains($0.0) }.count > 0
    }
    var pay5Parameters: [String] = ["main 1",
                                    "main 2",
                                    "main 3",
                                    "main 4",
                                    "main 5"]
    var result: AnalysisResults = ["main 1": GINIExtraction(name: "main 1",
                                                                     value: "test value",
                                                                     entity: "entity",
                                                                     box: [:])!,
                                            "other 1": GINIExtraction(name: "other 1",
                                                                      value: "other test value",
                                                                      entity: "other entity",
                                                                      box: [:])!]
    
    private(set) var feedBackSent: Bool = false
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        isAnalyzing = true
    }
    
    func cancelAnalysis() {
        isAnalyzing = false
        result = [:]
    }
    
    func sendFeedback(with: AnalysisResults) {
        feedBackSent = true
    }
    
    func remove(document: GiniVisionDocument) {
        
    }
    
    func resetToInitialState() {
        
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument]) {
        
    }
    
    func upload(document: GiniVisionDocument, completion: UploadDocumentCompletion?) {
        
    }
    
    func update(imageDocument: GiniImageDocument) {
        
    }
}
