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
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish:())
}

final class ScreenAPICoordinator: NSObject, Coordinator {
    
    weak var delegate: ScreenAPICoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return screenAPIViewController!
    }
    lazy var screenAPIViewController: UINavigationController? = {
        return GiniVision.viewController(withDelegate: self,
                                         withConfiguration: self.visionConfiguration,
                                         importedDocument: self.visionDocument) as? UINavigationController
    }()
    lazy var giniConfiguration = GiniConfiguration()
    
    weak var analysisDelegate: AnalysisDelegate?
    var visionDocument: GiniVisionDocument?
    var visionConfiguration: GiniConfiguration = GiniConfiguration()
    
    init(importedDocument document: GiniVisionDocument?) {
        self.visionDocument = document
    }
    
    fileprivate func showResultsScreen() {

    }
    
    fileprivate func showNoResultsScreen() {

    }
    
}

// MARK: GiniVisionDelegate

extension ScreenAPICoordinator: GiniVisionDelegate {
    
    func didCapture(document: GiniVisionDocument) {

    }
    
    func didReview(document: GiniVisionDocument, withChanges changes: Bool) {

    }
    
    func didCancelCapturing() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
    
    // Optional delegate methods
    func didCancelReview() {

    }
    
    func didShowAnalysis(_ analysisDelegate: AnalysisDelegate) {
    }
    
    func didCancelAnalysis() {
    }
    
}

