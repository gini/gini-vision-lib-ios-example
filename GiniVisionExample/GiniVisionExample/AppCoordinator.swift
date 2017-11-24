//
//  AppCoordinator.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import UIKit
import Gini_iOS_SDK

final class AppCoordinator: Coordinator {
    var rootViewController: UIViewController {
        return mainViewController
    }
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    lazy var documentService: DocumentService = DocumentService()
    
    lazy var mainViewController: MainViewController = {
        let mainViewController = MainViewController(nibName: nil, bundle: nil)
        mainViewController.delegate = self
        return mainViewController
    }()

    lazy var resultViewController: ResultsViewController? = {
        let ibanExtraction = GINIExtraction(name: "iban", value: "DE 1234 5678 9123 4567", entity: "entity", box: [:])
        let paymentRecipientExtraction = GINIExtraction(name: "paymentRecipient",
                                                        value: "Rick Sanchez", entity: "entity", box: [:])
        
        let result: [String: GINIExtraction] = ["iban": ibanExtraction!,
                                                "paymentRecipient": paymentRecipientExtraction!]
        self.documentService.result = result
        let resultViewController = ResultsViewController(model: ResultsViewModel(documentService: self.documentService))
        resultViewController.delegate = self
        return resultViewController
    }()

    lazy var pdfNoResultsViewController: PDFNoResultsViewController = {
        let noResults = PDFNoResultsViewController(nibName: nil, bundle: nil)
        noResults.delegate = self
        return noResults
    }()

    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        showMainViewController()
    }
    
    fileprivate func showMainViewController() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func showResultsViewController() {
        rootViewController.present(resultViewController!, animated: true, completion: nil)
    }
}

// MARK: ResultsViewControllerDelegate

extension AppCoordinator: ResultsViewControllerDelegate {
    
    func results(viewController: ResultsViewController, didTapDone: ()) {
        resultViewController?.dismiss(animated: true, completion: nil)
    }

    fileprivate func showHelpViewController() {
        let helpCoordinator = HelpCoordinator()
        helpCoordinator.delegate = self
        add(childCoordinator: helpCoordinator)
        rootViewController.present(helpCoordinator.rootViewController, animated: true, completion: nil)
    }
}

// MARK: MainViewControllerDelegate

extension AppCoordinator: MainViewControllerDelegate {
    
    func main(viewController: MainViewController, didTapStartAnalysis: ()) {
        let screenAPICoordinator = ScreenAPICoordinator(importedDocument: nil)
        screenAPICoordinator.delegate = self
        add(childCoordinator: screenAPICoordinator)
        rootViewController.present(screenAPICoordinator.rootViewController, animated: true, completion: nil)
    }
    
    func main(viewController: MainViewController, didTapShowHelp: ()) {
        showHelpViewController()
    }
    
}

// MARK: HelpCoordinatorDelegate

extension AppCoordinator: HelpCoordinatorDelegate {
    func help(coordinator: HelpCoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        remove(childCoordinator: coordinator)
    }
}


extension AppCoordinator: PDFNoResultsViewControllerDelegate {
    func pdfNoResults(viewController: PDFNoResultsViewController, didTapStartOver: ()) {
    }
}
// MARK: ScreenAPICoordinatorDelegate

extension AppCoordinator: ScreenAPICoordinatorDelegate {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        remove(childCoordinator: coordinator)
    }
}

