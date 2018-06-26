//
//  ScreenAPICoordinator.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 11/24/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import GiniVision
import Gini_iOS_SDK

protocol ScreenAPICoordinatorDelegate: class {
    func screenAPI(coordinator: ScreenAPICoordinator, didCancel:())
    func screenAPI(coordinator: ScreenAPICoordinator, didFinishWithResults results: AnalysisResults)
}

final class ScreenAPICoordinator: NSObject, Coordinator {
    
    weak var delegate: ScreenAPICoordinatorDelegate?
    var giniConfiguration: GiniConfiguration
    var documentService: DocumentServiceProtocol
    var childCoordinators: [Coordinator] = []
    var screenAPIViewController: UIViewController!
    var rootViewController: UIViewController {
        return screenAPIViewController
    }
    
//    lazy var documentAnalysisHandler: DocumentAnalysisCompletion = {[weak self] results, document, error in
//        guard let `self` = self else { return }
//        DispatchQueue.main.async {
//            if error != nil {
//                self.screenAPIAnalysisScreenDelegate?
//                    .displayError(withMessage: "Es ist ein Fehler aufgetreten. Wiederholen",
//                                  andAction: {
//                                    if let visionDocument = self.visionDocument {
//                                        self.documentService.analyze(visionDocument: visionDocument,
//                                                                     completion: self.documentAnalysisHandler)
//                                    }
//                    })
//                return
//            }
//            if self.documentService.hasExtractions ||
//                !(self.screenAPIAnalysisScreenDelegate?.tryDisplayNoResultsScreen() ?? false) {
//                self.delegate?.screenAPI(coordinator: self, didFinishWithResults: self.documentService.result)
//            }
//        }
//    }
    
    init(importedDocument document: GiniVisionDocument?,
         documentService: DocumentServiceProtocol,
         giniConfiguration: GiniConfiguration) {
        self.documentService = documentService
        self.giniConfiguration = giniConfiguration
        super.init()
        self.screenAPIViewController = GiniVision.viewController(withDelegate: self,
                                                                 withConfiguration: giniConfiguration,
                                                                 importedDocument: document)
    }
    
}

// MARK: GiniVisionDelegate

extension ScreenAPICoordinator: GiniVisionDelegate {
    
    func didCancelCapturing() {
        delegate?.screenAPI(coordinator: self, didCancel: ())
    }
    
    func didCapture(document: GiniVisionDocument, networkDelegate: GiniVisionNetworkDelegate) {
        // When an non reviewable document or an image in multipage mode is captured,
        // it has to be uploaded right away.
        if giniConfiguration.multipageEnabled || !document.isReviewable {
            if !document.isReviewable {
                self.uploadAndStartAnalysis(document: document, networkDelegate: networkDelegate, uploadDidFail: {
                    self.didCapture(document: document, networkDelegate: networkDelegate)
                })
            } else if giniConfiguration.multipageEnabled {
                // When multipage is enabled the document updload result should be communicated to the network delegate
                upload(document: document,
                       didComplete: networkDelegate.uploadDidComplete,
                       didFail: networkDelegate.uploadDidFail)
            }
        }
    }
    
    func didReview(documents: [GiniVisionDocument], networkDelegate: GiniVisionNetworkDelegate) {
        // It is necessary to check the order when using multipage before
        // creating the composite document
        if giniConfiguration.multipageEnabled {
            documentService.sortDocuments(withSameOrderAs: documents)
        }
        
        // And review the changes for each document recursively.
        for document in (documents.compactMap { $0 as? GiniImageDocument }) {
            documentService.update(imageDocument: document)
        }
        
        // In multipage mode the analysis can be triggered once the documents have been uploaded.
        // However, in single mode, the analysis can be triggered right after capturing the image.
        // That is why the document upload shuld be done here and start the analysis afterwards
        if giniConfiguration.multipageEnabled {
            self.startAnalysis(networkDelegate: networkDelegate)
        } else {
            self.uploadAndStartAnalysis(document: documents[0], networkDelegate: networkDelegate, uploadDidFail: {
                self.didReview(documents: documents, networkDelegate: networkDelegate)
            })
        }
    }
    
    func didCancelReview(for document: GiniVisionDocument) {
        documentService.remove(document: document)
    }
    
    func didCancelAnalysis() {
        // Cancel analysis process to avoid unnecessary network calls.
        documentService.cancelAnalysis()
    }
    
}

// MARK: - Networking methods

extension ScreenAPICoordinator {
    fileprivate func startAnalysis(networkDelegate: GiniVisionNetworkDelegate) {
        self.documentService.startAnalysis { result in
            switch result {
            case .success(let extractions):
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.delegate?.screenAPI(coordinator: self, didFinishWithResults: extractions)
                }
            case .failure(let error):
                let error = error as? AnalysisError ?? AnalysisError.unknown
                guard error != .cancelled else { return }
                
                networkDelegate.displayError(withMessage: error.message, andAction: {
                    self.startAnalysis(networkDelegate: networkDelegate)
                })
            }
        }
    }
    
    fileprivate func upload(document: GiniVisionDocument,
                            didComplete: @escaping (GiniVisionDocument) -> Void,
                            didFail: @escaping (GiniVisionDocument, Error) -> Void) {
        documentService.upload(document: document) { result in
            switch result {
            case .success:
                didComplete(document)
            case .failure(let error):
                didFail(document, error)
            }
        }
    }
    
    fileprivate func uploadAndStartAnalysis(document: GiniVisionDocument,
                                            networkDelegate: GiniVisionNetworkDelegate,
                                            uploadDidFail: @escaping () -> Void) {
        self.upload(document: document, didComplete: { _ in
            self.startAnalysis(networkDelegate: networkDelegate)
        }, didFail: { _, error in
            let error = error as? GiniVisionError ?? AnalysisError.documentCreation
            networkDelegate.displayError(withMessage: error.message, andAction: {
                uploadDidFail()
            })
        })
    }
}

