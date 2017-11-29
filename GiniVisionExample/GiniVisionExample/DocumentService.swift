//
//  DocumentService.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
@testable import Gini_iOS_SDK
@testable import GiniVision

typealias AnalysisResults = [String: GINIExtraction]
typealias DocumentAnalysisCompletion = ((AnalysisResults?, GINIDocument?, Error?) -> Void)

protocol DocumentServiceProtocol: class {
    
    var isAnalyzing: Bool { get }
    var isCancelled: Bool { get }
    var hasExtractions: Bool { get }
    var pay5Parameters: [String] { get }
    var result: AnalysisResults { get }
    
    func analyze(visionDocument: GiniVisionDocument, completion: @escaping  DocumentAnalysisCompletion)
    func cancelAnalysis()
    func sendFeedback(withUpdatedResults results: AnalysisResults)
}

final class DocumentService: DocumentServiceProtocol {
    var isAnalyzing: Bool = false
    var isCancelled: Bool = false
    var hasExtractions: Bool {
        return result.filter { pay5Parameters.contains($0.0) }.count > 0
    }

    var pay5Parameters: [String] = ["paymentRecipient", "iban", "bic", "paymentReference", "amountToPay"]
    var result: AnalysisResults = [:]
    var giniSDK: GiniSDK?
    
    private lazy var credentials: (id: String?, password: String?) = {
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        return (keys?["client_id"] as? String, keys?["client_password"] as? String)
    }()
    
    init() {
        let clientId = credentials.id
        let clientSecret = credentials.password

        let domain = "giniexample.com"
        
        self.giniSDK = GINISDKBuilder.anonymousUser(withClientID: clientId,
                                                    clientSecret: clientSecret,
                                                    userEmailDomain: domain).build()
    }
    
    func analyze(visionDocument: GiniVisionDocument, completion: @escaping  DocumentAnalysisCompletion) {
        isAnalyzing = true
        isCancelled = false
        
        print("🔎 Started document analysis with size \(Double(visionDocument.data.count) / 1024.0)")
        
        // Get current Gini SDK instance to upload image and process exctraction.
        let sdk = giniSDK
        
        // Create a document task manager to handle document tasks on the Gini API.
        let manager = sdk?.documentTaskManager
        
        // Create a file name for the document.
        let fileName = "exampleDocument"
        
        var documentId: String?
        var document: GINIDocument?
        
        // 1. Get session
        _ = sdk?.sessionManager.getSession().continue({ (task: BFTask?) -> Any! in
            if task?.error != nil {
                return sdk?.sessionManager.logIn()
            }
            return task?.result
            
            // 2. Create a document from the given image data
        }).continue(successBlock: { (_: BFTask?) -> AnyObject! in
            
            if self.isCancelled {
                print("❌ Canceled analysis process")
                BFTask.cancelled()
            }

            return manager?.createDocument(withFilename: fileName, from: visionDocument.data, docType: "")
            
            // 3. Get extractions from the document
        }).continue(successBlock: { (task: BFTask?) -> AnyObject! in
            if self.isCancelled {
                print("❌ Canceled analysis process")
                BFTask.cancelled()
            }
            
            if let documentGenerated = task?.result as? GINIDocument {
                documentId = documentGenerated.documentId
                document = documentGenerated
                print("📄 Created document with id: \(documentId!)")
            } else {
                print("Error creating document")
            }
            
            return document?.extractions
            
            // 4. Handle results
        }).continue({ (task: BFTask?) -> AnyObject! in
            if self.isCancelled {
                print("❌ Canceled analysis process")
                return BFTask.cancelled()
            }
            
            print("✅ Finished analysis process")
            self.result = (task?.result as? AnalysisResults) ?? [:]
            completion(self.result, document, task?.error)
            
            return nil
            
            // 5. Finish process
        }).continue({ (_: BFTask?) -> AnyObject! in
            self.isAnalyzing = false
            return nil
        })

    }
    
    func cancelAnalysis() {
        isAnalyzing = false
        isCancelled = true
        result = [:]
    }
    
    func sendFeedback(withUpdatedResults results: AnalysisResults) {
        
    }
}
