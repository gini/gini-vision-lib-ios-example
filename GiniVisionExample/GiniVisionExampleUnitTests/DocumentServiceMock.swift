//
//  DocumentServiceMock.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
@testable import GiniVisionExample
@testable import Gini_iOS_SDK

final class DocumentServiceMock: DocumentServiceProtocol {
    
    var pay5Parameters: [String] = ["main parameter 1",
                                    "main parameter 2",
                                    "main parameter 3",
                                    "main parameter 4",
                                    "main parameter 5"]
    var result: [String: GINIExtraction] = ["main parameter 1": GINIExtraction(name: "name",
                                                                               value: "test value",
                                                                               entity: "entity",
                                                                               box: [:])!,
                                            "other parameter 1": GINIExtraction(name: "other name",
                                                                               value: "other test value",
                                                                               entity: "other entity",
                                                                               box: [:])!]
    
    private(set) var feedBackSent: Bool = false
    
    func sendFeedback(withUpdatedResults results: AnalysisResults) {
        feedBackSent = true
    }
}
