//
//  DocumentService.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
@testable import Gini_iOS_SDK

typealias AnalysisResults = [String: GINIExtraction]

protocol DocumentServiceProtocol: class {
    
    var pay5Parameters: [String] { get }
    var result: [String: GINIExtraction] { get }
    
    func sendFeedback(withUpdatedResults results: AnalysisResults)
}

final class DocumentService: DocumentServiceProtocol {
    var pay5Parameters: [String] = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
    var result: [String: GINIExtraction] = [:]
    
    func sendFeedback(withUpdatedResults results: AnalysisResults) {
        
    }
}
