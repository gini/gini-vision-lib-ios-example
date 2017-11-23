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
    var sections: [Results] = [("Section 0", [("item 1", "value 1"), ("item 2", "value 1")])]
    
    var documentService: DocumentServiceProtocol
    
    init(result: [String: GINIExtraction], documentService: DocumentServiceProtocol = DocumentService()) {
        self.documentService = documentService
    }
    
    func sendFeedBack() {
        
    }
    
}
