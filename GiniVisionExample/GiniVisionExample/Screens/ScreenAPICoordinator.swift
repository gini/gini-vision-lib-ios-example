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
    weak var screenAPIAnalysisScreenDelegate: AnalysisDelegate?
    var visionDocument: GiniVisionDocument?
    var documentService: DocumentServiceProtocol
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return screenAPIViewController!
    }
    
    lazy var screenAPIViewController: UIViewController? = {
        return GiniVision.viewController(withDelegate: self,
                                         withConfiguration: self.visionConfiguration,
                                         importedDocument: self.visionDocument)
    }()
    
    lazy var visionConfiguration: GiniConfiguration = {
        let configuration = GiniConfiguration()
        configuration.fileImportSupportedTypes = .pdf_and_images
        configuration.openWithEnabled = true
        configuration.navigationBarItemTintColor = .white
        configuration.navigationBarTintColor = .giniBlue
        configuration.qrCodeScanningEnabled = true
        return configuration
    }()
    
    lazy var documentAnalysisHandler: DocumentAnalysisCompletion = {[weak self] results, document, error in
        guard let `self` = self else { return }
        DispatchQueue.main.async {
            if error != nil {
                self.screenAPIAnalysisScreenDelegate?
                    .displayError(withMessage: "Es ist ein Fehler aufgetreten. Wiederholen",
                                  andAction: {
                                    if let visionDocument = self.visionDocument {
                                        self.documentService.analyze(visionDocument: visionDocument,
                                                                     completion: self.documentAnalysisHandler)
                                    }
                    })
                return
            }
            if self.documentService.hasExtractions ||
                !(self.screenAPIAnalysisScreenDelegate?.tryDisplayNoResultsScreen() ?? false) {
                self.delegate?.screenAPI(coordinator: self, didFinishWithResults: self.documentService.result)
            }
        }
    }
    
    init(importedDocument document: GiniVisionDocument?, documentService: DocumentServiceProtocol) {
        self.visionDocument = document
        self.documentService = documentService
    }
    
}

// MARK: GiniVisionDelegate

extension ScreenAPICoordinator: GiniVisionDelegate {
    
    
    func didCapture(document: GiniVisionDocument, networkDelegate: GiniVisionNetworkDelegate) {
        visionDocument = document
        documentService.analyze(visionDocument: document, completion: documentAnalysisHandler)
    }
    
    func didReview(documents: [GiniVisionDocument], networkDelegate: GiniVisionNetworkDelegate) {
        let document = documents[0]
        visionDocument = document
        
        if (!documentService.isAnalyzing && documentService.result.isEmpty) {
            documentService.analyze(visionDocument: document, completion: documentAnalysisHandler)
        }
    }
    
    func didCancelCapturing() {
        delegate?.screenAPI(coordinator: self, didCancel: ())
    }
    
    func didCancelReview(for document: GiniVisionDocument) {
        documentService.cancelAnalysis()
    }
    
    func didCancelAnalysis() {
        documentService.cancelAnalysis()
    }
    
}

