//
//  AccountingDocumentAnalysisHelper.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 4/8/19.
//  Copyright © 2019 Gini. All rights reserved.
//

import Foundation
import Gini
import GiniVision

final class AccountingDocumentAnalysisHelper: DocumentAnalysisHelper {
    
    let pay5Parameters: [String] = ["paymentRecipient", "iban", "bic", "paymentReference", "amountToPay"]
    var giniSDK: GiniSDK
    var documentService: AccountingDocumentService
    var document: Document?
    var analysisCancellationToken: CancellationToken?
    
    init(client: Client) {
        self.giniSDK = GiniSDK
            .Builder(client: client,
                     api: .accounting,
                     isLoggingEnabled: true)
            .build()
        self.documentService = giniSDK.documentService()
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        guard let document = document else { return }
        self.fetchExtractions(for: document, completion: completion)
    }
    
    func cancelAnalysis() {
        if let document = document {
            delete(document)
        }
        
        analysisCancellationToken?.cancel()
        analysisCancellationToken = nil
        document = nil
    }
    
    func remove(document: GiniVisionDocument) {
        guard let document = self.document else { return }
        delete(document)
    }
    
    func resetToInitialState() {
        analysisCancellationToken = nil
        document = nil
    }
    
    func update(imageDocument: GiniImageDocument) {
        // Multipage not supported
    }
    
    func sendFeedback(with updatedExtractions: [Extraction]) {
        guard let document = document else { return }
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
        // Multipage not supported
    }
    
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        let fileName = "Accounting-\(NSDate().timeIntervalSince1970)"
        
        createDocument(from: document, fileName: fileName) { result in
            switch result {
            case .success(let createdDocument):
                self.document = createdDocument
                
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}

// MARK: - File private methods

fileprivate extension AccountingDocumentAnalysisHelper {
    func createDocument(from document: GiniVisionDocument,
                        fileName: String,
                        docType: String = "",
                        completion: @escaping UploadDocumentCompletion) {
        print("📝 Creating document...")
        
        documentService.createDocument(with: document.data,
                                       fileName: fileName,
                                       docType: nil,
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
    
    func delete(_ document: Document) {
        documentService.delete(document) { result in
            switch result {
            case .success:
                print("🗑 Deleted document with id: \(document.id)")
            case .failure:
                print("❌ Error deleting document with id: \(document.id)")
            }
        }
    }
    
    func fetchExtractions(for document: Document,
                          completion: @escaping (Result<[Extraction], GiniError>) -> Void) {
        print("🔎 Starting analysis...")

        self.analysisCancellationToken = CancellationToken()
        self.documentService
            .extractions(for: document,
                         cancellationToken: self.analysisCancellationToken!,
                         completion: self.handleResults(completion: completion))
    }
}
