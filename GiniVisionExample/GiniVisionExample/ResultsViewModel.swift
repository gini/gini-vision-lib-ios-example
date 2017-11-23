//
//  ResultsViewModel.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import Gini_iOS_SDK

typealias Results = (title: String, items: [(name: String, value: String)])

protocol ResultsViewModelProtocol: class {
    
    var sections: [Results] { get set }
    var documentService: DocumentServiceProtocol { get }
    
    init(result: [String: GINIExtraction], documentService: DocumentServiceProtocol)
    func sendFeedBack()
}

final class ResultsViewModel: ResultsViewModelProtocol {

    var sections: [Results] = [("Section 0", [("item 1", "value 1"), ("item 2", "value 1")])]
    var documentService: DocumentServiceProtocol
    
    init(result: [String : GINIExtraction], documentService: DocumentServiceProtocol = DocumentService()) {
        self.documentService = documentService
    }
    
    func sendFeedBack() {
        
    }
}
