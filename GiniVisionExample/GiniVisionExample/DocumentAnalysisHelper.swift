//
//  DocumentService.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import GiniVision
import Gini

typealias UploadDocumentCompletion = (Result<Document, GiniError>) -> Void
typealias AnalysisCompletion = (Result<ExtractionResult, GiniError>) -> Void

protocol DocumentAnalysisHelper: AnyObject {
    
    var analysisCancellationToken: CancellationToken? { get set }
    var pay5Parameters: [String] { get }

    func cancelAnalysis()
    func remove(document: GiniVisionDocument)
    func resetToInitialState()
    func sendFeedback(with: [Extraction])
    func startAnalysis(completion: @escaping AnalysisCompletion)
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument])
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?)
    func update(imageDocument: GiniImageDocument)
}

extension DocumentAnalysisHelper {
    func handleResults(completion: @escaping AnalysisCompletion) -> (CompletionResult<ExtractionResult>){
        return { result in
            switch result {
            case .success(let extractionResult):
                print("✅ Finished analysis process with no errors")
                completion(.success(extractionResult))
            case .failure(let error):
                switch error {
                case .requestCancelled:
                    print("❌ Cancelled analysis process")
                default:
                    print("❌ Finished analysis process with error: \(error)")
                }
            }
        }
        
    }
}

