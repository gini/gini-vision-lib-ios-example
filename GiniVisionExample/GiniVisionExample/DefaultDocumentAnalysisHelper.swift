//
//  DefaultDocumentAnalysisHelper.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 4/8/19.
//  Copyright © 2019 Gini. All rights reserved.
//

import Foundation
import Gini
import GiniVision

final class DefaultDocumenAnalysisHelper: DocumentAnalysisHelper {
    
    let pay5Parameters: [String] = ["paymentRecipient", "iban", "bic", "paymentReference", "amountToPay"]
    var giniSDK: GiniSDK
    var documentService: DefaultDocumentService
    var partialDocuments: [String: PartialDocument] = [:]
    var compositeDocument: Document?
    var analysisCancellationToken: CancellationToken?
    
    init(client: Client) {        
        self.giniSDK = GiniSDK
            .Builder(client: client)
            .build()
        self.documentService = giniSDK.documentService()
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments
            .lazy
            .map { $0.value }
            .sorted()
            .map { $0.info }
        
        self.fetchExtractions(for: partialDocumentsInfoSorted, completion: completion)
    }
    
    func cancelAnalysis() {
        if let compositeDocument = compositeDocument {
            delete(composite: compositeDocument)
        }
        
        analysisCancellationToken?.cancel()
        analysisCancellationToken = nil
        compositeDocument = nil
    }
    
    func remove(document: GiniVisionDocument) {
        if let index = partialDocuments.index(forKey: document.id) {
            if let partial = partialDocuments[document.id]?
                .document {
                delete(partial: partial)
            }
            partialDocuments.remove(at: index)
        }
    }
    
    func resetToInitialState() {
        partialDocuments.removeAll()
        analysisCancellationToken = nil
        compositeDocument = nil
    }
    
    func update(imageDocument: GiniImageDocument) {
        partialDocuments[imageDocument.id]?.info.rotationDelta = imageDocument.rotationDelta
    }
    
    func sendFeedback(with updatedExtractions: [Extraction]) {
        guard let document = compositeDocument else { return }
        documentService
            .submitFeedback(for: document,
                            with: updatedExtractions) { result in
                                switch result {
                                case .success:
                                    print("🚀 Feedback sent with \(updatedExtractions.count) extractions")
                                case .failure(let error):
                                    let message = "❌ Error sending feedback for docId: \(document.id) error: \(error)"
                                    print(message)
                                }
                                
        }
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument]) {
        for index in 0..<documents.count {
            let id = documents[index].id
            partialDocuments[id]?.order = index
        }
    }
    
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        self.partialDocuments[document.id] =
            PartialDocument(info: (Gini.PartialDocumentInfo(document: nil, rotationDelta: 0)),
                                document: nil,
                                order: self.partialDocuments.count)
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"
        
        createDocument(from: document, fileName: fileName) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments[document.id]?.info.document = createdDocument.links.document
                self.partialDocuments[document.id]?.document = createdDocument
                
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}

// MARK: - File private methods

fileprivate extension DefaultDocumenAnalysisHelper {
    func createDocument(from document: GiniVisionDocument,
                        fileName: String,
                        docType: String = "",
                        completion: @escaping UploadDocumentCompletion) {
        print("📝 Creating document...")
        
        documentService.createDocument(fileName: fileName,
                                       docType: nil,
                                       type: .partial(document.data),
                                       metadata: nil) { result in
                                        switch result {
                                        case .success(let createdDocument):
                                            print("📄 Created document with id: \(createdDocument.id) for vision document \(document.id)")
                                            completion(.success(createdDocument))
                                        case .failure(let error):
                                            print("❌ Document creation failed \(error)")
                                        }
                                        
        }
    }
    
    func delete(composite document: Document) {
        documentService.delete(document) { result in
            switch result {
            case .success:
                print("🗑 Deleted composite document with id: \(document.id)")
            case .failure:
                print("❌ Error deleting composite document with id: \(document.id)")
            }
        }
    }
    
    func delete(partial document: Document) {
        documentService.delete(document) { result in
            switch result {
            case .success:
                print("🗑 Deleted partial document with id: \(document.id)")
            case .failure:
                print("❌ Error deleting partial document with id: \(document.id)")
            }
        }
    }
    
    func fetchExtractions(for documents: [Gini.PartialDocumentInfo],
                          completion: @escaping AnalysisCompletion) {
        print("📑 Creating composite document...")
        
        let fileName = "Composite-\(NSDate().timeIntervalSince1970)"
        
        documentService
            .createDocument(fileName: fileName,
                            docType: nil,
                            type: .composite(.init(partialDocuments: documents)),
                            metadata: nil) { result in
                                switch result {
                                case .success(let compositeDocument):
                                    print("🔎 Starting analysis...")
                                    self.compositeDocument = compositeDocument
                                    self.analysisCancellationToken = CancellationToken()
                                    self.documentService
                                        .extractions(for: compositeDocument,
                                                     cancellationToken: self.analysisCancellationToken!,
                                                     completion: self.handleResults(completion: completion))
                                case .failure(let error):
                                    print("❌ Error creating composite document")
                                    completion(.failure(error))
                                }
        }
        
    }
}
