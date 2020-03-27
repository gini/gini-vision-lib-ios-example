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
@testable import Gini

final class DocumentServiceMock: DefaultDocumentServiceProtocol {
    
    var apiDomain: APIDomain = .default
    
    var compositeDocument: Document?
    var analysisCancellationToken: CancellationToken?
    
    var isAnalyzing: Bool = false
    var hasExtractions: Bool {
        return result.filter { pay5Parameters.contains($0.name!) }.count > 0
    }
    var pay5Parameters: [String] = ["main 1",
                                    "main 2",
                                    "main 3",
                                    "main 4",
                                    "main 5"]
    var result: [Extraction] = [Extraction(box: nil,
                                           candidates: nil,
                                           entity: "entity",
                                           value: "test value",
                                           name: "main 1"),
                                Extraction(box: nil,
                                           candidates: nil,
                                           entity: "entity",
                                           value: "other test value",
                                           name: "other 1")]
    
    private(set) var feedBackSent: Bool = false
    
    func submitFeedback(for document: Document,
                        with extractions: [Extraction],
                        completion: @escaping CompletionResult<Void>) {
        
    }
    
    func pagePreview(for document: Document,
                     pageNumber: Int,
                     size: Document.Page.Size,
                     completion: @escaping CompletionResult<Data>) {
        
    }
    
    func pages(in document: Document, completion: @escaping CompletionResult<[Document.Page]>) {
        
    }
    
    func layout(for document: Document, completion: @escaping CompletionResult<Document.Layout>) {
        
    }
    
    func fetchDocument(with id: String, completion: @escaping CompletionResult<Document>) {
        
    }
    
    func extractions(for document: Document,
                     cancellationToken: CancellationToken,
                     completion: @escaping CompletionResult<ExtractionResult>) {
        
    }
    
    func documents(limit: Int?, offset: Int?, completion: @escaping CompletionResult<[Document]>) {
        
    }
    
    func delete(_ document: Document, completion: @escaping CompletionResult<String>) {
        
    }
    
    func createDocument(fileName: String?,
                        docType: Document.DocType?,
                        type: Document.TypeV2,
                        metadata: Document.Metadata?,
                        completion: @escaping CompletionResult<Document>) {
        
    }
}
