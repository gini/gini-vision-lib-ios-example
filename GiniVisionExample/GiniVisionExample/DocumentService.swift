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

typealias AnalysisResults = [String: GINIExtraction]
typealias DocumentAnalysisCompletion = ((AnalysisResults?, GINIDocument?, Error?) -> Void)

protocol DocumentServiceProtocol: class {
    
    var isAnalyzing: Bool { get }
    var isCancelled: Bool { get }
    var hasExtractions: Bool { get }
    var pay5Parameters: [String] { get }
    var result: AnalysisResults { get set }
    
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
    var giniDocument: GINIDocument?
    let clientID = "client_id"
    let clientPassword = "client_password"
    
    private lazy var credentials: (id: String?, password: String?) = {
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let keys = NSDictionary(contentsOfFile: path),
            let clientId = keys[self.clientID] as? String,
            let clientPassword = keys[self.clientPassword] as? String,
            !clientId.isEmpty, !clientPassword.isEmpty {
            
            return (clientId, clientPassword)
        }
        return (ProcessInfo.processInfo.environment[self.clientID],
                ProcessInfo.processInfo.environment[self.clientPassword])
    }()
    
    init() {
        let clientId = credentials.id ?? ""
        let clientSecret = credentials.password ?? ""
        let domain = "giniexample.com"
        
        self.giniSDK = GINISDKBuilder.anonymousUser(withClientID: clientId,
                                                    clientSecret: clientSecret,
                                                    userEmailDomain: domain).build()
    }
    
    func analyze(visionDocument: GiniVisionDocument, completion: @escaping  DocumentAnalysisCompletion) {
        isAnalyzing = true
        isCancelled = false
        
        print("🔎 Started document analysis with size \(Double(visionDocument.data.count) / 1024.0)")
        
        // Create a document task manager to handle document tasks on the Gini API.
        let manager = self.giniSDK?.documentTaskManager
        
        // Create a file name for the document.
        let fileName = "exampleDocument"
        
        var documentId: String?
        var document: GINIDocument?
        
        // 1. Get session
        _ = giniSDK?.sessionManager.getSession().continue({ (task: BFTask?) -> Any! in
            if task?.error != nil {
                return self.giniSDK?.sessionManager.logIn()
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
            self.giniDocument = document
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
        giniDocument = nil
    }
    
    func sendFeedback(withUpdatedResults results: AnalysisResults) {
        
        _ = giniSDK?.sessionManager.getSession().continue({ (task: BFTask?) -> Any? in
            if task?.error != nil {
                return self.giniSDK?.sessionManager.logIn()
            }
            return task?.result
            
        }).continue(successBlock: { (_: BFTask?) -> AnyObject! in
            
            return self.giniDocument?.extractions
            
        }).continue(successBlock: { (task: BFTask?) -> AnyObject! in
            
            if let extractions = task?.result as? NSMutableDictionary {
                results.forEach { result in
                    extractions[result.key] = result.value
                }
                
                let documentTaskManager = self.giniSDK?.documentTaskManager
                
                return documentTaskManager?.update(self.giniDocument)
            }
            
            return nil

        }).continue(successBlock: { (_: BFTask?) -> AnyObject! in
            return self.giniDocument?.extractions
            
            // 5. Handle results
        }).continue({ (task: BFTask?) -> AnyObject! in
            if task?.error != nil {
                print("Error sending feedback for document with id: ",
                      String(describing: self.giniDocument?.documentId))
                return nil
            }
            
            print("🚀 Feedback sent")
            return nil
        })
    }
}
