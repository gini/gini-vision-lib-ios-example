//
//  DocumentService.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import Gini_iOS_SDK
import GiniVision

enum Result<T> {
    case success(T)
    case failure(Error)
}

typealias AnalysisResults = [String: GINIExtraction]
typealias UploadDocumentCompletion = (Result<GINIDocument>) -> Void
typealias AnalysisCompletion = (Result<AnalysisResults>) -> Void

protocol DocumentServiceProtocol: class {
    
    var giniSDK: GiniSDK { get }
    var compositeDocument: GINIDocument? { get set }
    var analysisCancellationToken: BFCancellationTokenSource? { get set }
    var pay5Parameters: [String] { get }
    
    func cancelAnalysis()
    func remove(document: GiniVisionDocument)
    func resetToInitialState()
    func sendFeedback(with: AnalysisResults)
    func startAnalysis(completion: @escaping AnalysisCompletion)
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument])
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?)
    func update(imageDocument: GiniImageDocument)
}

final class DocumentService: DocumentServiceProtocol {
    
    let pay5Parameters: [String] = ["paymentRecipient", "iban", "bic", "paymentReference", "amountToPay"]
    var giniSDK: GiniSDK
    var partialDocuments: [String: PartialDocumentInfo] = [:]
    var compositeDocument: GINIDocument?
    var analysisCancellationToken: BFCancellationTokenSource?
    
    init() {
        let credentials = DocumentService.fetchCredentials()
        let clientId = credentials.id ?? ""
        let clientSecret = credentials.password ?? ""
        let domain = "giniexample.com"
        
        self.giniSDK = GINISDKBuilder.anonymousUser(withClientID: clientId,
                                                    clientSecret: clientSecret,
                                                    userEmailDomain: domain).build()
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
            deleteCompositeDocument(withId: compositeDocument.documentId)
        }
        
        analysisCancellationToken?.cancel()
        analysisCancellationToken = nil
        compositeDocument = nil
    }
    
    func remove(document: GiniVisionDocument) {
        if let index = partialDocuments.index(forKey: document.id) {
            if let partialDocumentId = partialDocuments[document.id]?
                .info
                .documentId {
                deletePartialDocument(withId: partialDocumentId)
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
        partialDocuments[imageDocument.id]?.info.rotationDelta = Int32(imageDocument.rotationDelta)
    }
    
    func sendFeedback(with updatedExtractions: AnalysisResults) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: sessionBlock())
            .continueOnSuccessWith(block: { _ in
                return self.giniSDK
                    .documentTaskManager?
                    .update(self.compositeDocument,
                            updatedExtractions: updatedExtractions,
                            cancellationToken: nil)
            })
            .continueWith(block: { (task: BFTask?) in
                if let error = task?.error {
                    let id = self.compositeDocument?.documentId ?? ""
                    let message = "❌ Error sending feedback for document with id: \(id) error: \(error)"
                    print(message)
                    
                    return nil
                }
                
                print("🚀 Feedback sent with \(updatedExtractions.count) extractions")
                return nil
            })
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
            PartialDocumentInfo(info: (GINIPartialDocumentInfo(documentUrl: nil, rotationDelta: 0)),
                                order: self.partialDocuments.count)
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"
        
        createDocument(from: document, fileName: fileName) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments[document.id]?.info.documentUrl = createdDocument.links.document
                
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    class func fetchCredentials() -> (id: String?, password: String?) {
        let clientID = "client_id"
        let clientPassword = "client_password"
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let keys = NSDictionary(contentsOfFile: path),
            let client_id = keys[clientID] as? String,
            let client_password = keys[clientPassword] as? String,
            !client_id.isEmpty, !client_password.isEmpty {
            
            return (client_id, client_password)
        }
        return ("", "")
    }
}

// MARK: - File private methods

extension DocumentService {
    fileprivate func createDocument(from document: GiniVisionDocument,
                                    fileName: String,
                                    docType: String = "",
                                    cancellationToken: BFCancellationToken? = nil,
                                    completion: @escaping UploadDocumentCompletion) {
        print("📝 Creating document...")
        
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: sessionBlock(cancellationToken: cancellationToken))
            .continueOnSuccessWith(block: { [weak self] _ in
                return self?.giniSDK.documentTaskManager.createPartialDocument(withFilename: fileName,
                                                                               from: document.data,
                                                                               docType: docType,
                                                                               cancellationToken: cancellationToken)
            }).continueWith(block: { task in
                if let createdDocument = task.result as? GINIDocument {
                    print("📄 Created document with id: \(createdDocument.documentId ?? "") " +
                        "for vision document \(document.id)")
                    completion(.success(createdDocument))
                } else if task.isCancelled {
                    print("❌ Document creation was cancelled")
                    completion(.failure(AnalysisError.cancelled))
                } else {
                    print("❌ Document creation failed")
                    completion(.failure(AnalysisError.documentCreation))
                }
                
                return nil
            })
    }
    
    fileprivate func deleteCompositeDocument(withId id: String) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: sessionBlock(cancellationToken: nil))
            .continueOnSuccessWith(block: { [weak self] _ in
                self?.giniSDK.documentTaskManager.deleteCompositeDocument(withId: id,
                                                                          cancellationToken: nil)
            })
            .continueWith(block: { task in
                if task.isCancelled || task.error != nil {
                    print("❌ Error deleting composite document with id: \(id)")
                } else {
                    print("🗑 Deleted composite document with id: \(id)")
                }
                
                return nil
            })
        
    }
    
    fileprivate func deletePartialDocument(withId id: String) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: sessionBlock(cancellationToken: nil))
            .continueOnSuccessWith(block: { [weak self] _ in
                self?.giniSDK.documentTaskManager.deletePartialDocument(withId: id,
                                                                        cancellationToken: nil)
            })
            .continueWith(block: { task in
                if task.isCancelled || task.error != nil {
                    print("❌ Error deleting partial document with id: \(id)")
                } else {
                    print("🗑 Deleted partial document with id: \(id)")
                }
                
                return nil
            })
        
    }
    
    fileprivate func fetchExtractions(for documents: [GINIPartialDocumentInfo],
                                      completion: @escaping AnalysisCompletion) {
        print(" 📑 Creating composite document...")
        
        analysisCancellationToken = BFCancellationTokenSource()
        let fileName = "Composite-\(NSDate().timeIntervalSince1970)"
        
        giniSDK
            .documentTaskManager
            .createCompositeDocument(withPartialDocumentsInfo: documents,
                                     fileName: fileName,
                                     docType: "",
                                     cancellationToken: analysisCancellationToken?.token)
            .continueOnSuccessWith { task in
                if let document = task.result as? GINIDocument {
                    print("🔎 Starting analysis...")
                    
                    self.compositeDocument = document
                    return self.giniSDK
                        .documentTaskManager
                        .getExtractionsFor(document,
                                           cancellationToken: self.analysisCancellationToken?.token)
                }
                return BFTask<AnyObject>(error: AnalysisError.documentCreation)
            }
            .continueWith(block: handleAnalysisResults(completion: completion))
        
    }
    
    fileprivate func handleAnalysisResults(completion: @escaping AnalysisCompletion)
        -> ((BFTask<AnyObject>) -> Any?) {
            return { task in
                if task.isCancelled {
                    print("❌ Cancelled analysis process")
                    completion(.failure(AnalysisError.cancelled))
                    
                    return BFTask<AnyObject>.cancelled()
                }
                
                let finishedString = "Finished analysis process with"
                
                if let error = task.error {
                    print("❌ \(finishedString) this error: \(error)")
                    
                    completion(.failure(error))
                } else if let result = task.result as? AnalysisResults {
                    print("✅ \(finishedString) no errors")
                    
                    completion(.success(result))
                } else {
                    let error = NSError(domain: "net.gini.error.", code: AnalysisError.unknown._code, userInfo: nil)
                    print("❌ \(finishedString) this error: \(error)")
                    
                    completion(.failure(AnalysisError.unknown))
                }
                
                return nil
            }
    }
    
    fileprivate func sessionBlock(cancellationToken token: BFCancellationToken? = nil)
        -> ((BFTask<AnyObject>) -> Any?) {
            return {
                [weak self] task in
                guard let `self` = self else { return nil }
                
                if task.error != nil {
                    return self.giniSDK.sessionManager.logIn()
                }
                return task.result
            }
    }
}
