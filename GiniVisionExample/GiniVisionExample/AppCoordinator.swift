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
import AVFoundation
import GiniVision

final class AppCoordinator: Coordinator {
    var rootViewController: UIViewController {
        return appNavigationController
    }
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    lazy var documentService: DocumentService = DocumentService()
    let application: UIApplication
    
    lazy var appNavigationController: UINavigationController = {
        let navController = UINavigationController(rootViewController: self.mainViewController)
        navController.isNavigationBarHidden = true
        return navController
    }()
    
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
    
    init(window: UIWindow, application: UIApplication) {
        self.window = window
        self.application = application
    }
    
    func start() {
        showMainViewController()
    }
    
    func processExternalDocument(withUrl url: URL, sourceApplication: String?) {
        let data = try? Data(contentsOf: url)
        
        let documentBuilder = GiniVisionDocumentBuilder(data: data, documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        let document = documentBuilder.build()
        
        // When a document is imported with "Open with", a dialog allowing to choose between both APIs
        // is shown in the main screen. Therefore it needs to go to the main screen if it is not there yet.
        popToRootViewControllerIfNeeded()
        
        do {
            try document?.validate()
            showScreenAPI(withImportedDocument: document)
        } catch {
            
        }
    }
    
    fileprivate func popToRootViewControllerIfNeeded() {
        self.appNavigationController.popToRootViewController(animated: true)
        self.childCoordinators.forEach(remove)
    }
    
    fileprivate func showMainViewController() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func showResultsViewController() {
        rootViewController.present(resultViewController!, animated: true, completion: nil)
    }

    fileprivate func showHelpViewController() {
        let helpCoordinator = HelpCoordinator()
        helpCoordinator.delegate = self
        add(childCoordinator: helpCoordinator)
        appNavigationController.pushViewController(helpCoordinator.rootViewController, animated: true)
    }
    
    fileprivate func showScreenAPI(withImportedDocument importedDocument: GiniVisionDocument?) {
        let screenAPICoordinator = ScreenAPICoordinator(importedDocument: importedDocument)

        screenAPICoordinator.delegate = self
        add(childCoordinator: screenAPICoordinator)
        appNavigationController.pushViewController(screenAPICoordinator.rootViewController, animated: true)
    }
    
    fileprivate func checkCameraPermissions(completion: @escaping (Bool) -> Void) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { authorized in
                completion(authorized)
            }
        }
    }
    
    fileprivate func showCameraPermissionDeniedError() {
        let alertMessage = "Um gespeicherte Bilder zu analysieren, wird Zugriff auf Ihre Camera."
        
        let alertViewController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        }))
        
        alertViewController.addAction(UIAlertAction(title: "Zugriff erteilen",
                                                    style: .default, handler: { [weak self] _ in
            alertViewController.dismiss(animated: true, completion: nil)
            self?.application.openAppSettings()
        }))
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
}

// MARK: MainViewControllerDelegate

extension AppCoordinator: MainViewControllerDelegate {
    
    func main(viewController: MainViewController, didTapStartAnalysis: ()) {
        checkCameraPermissions {[weak self] authorized in
            DispatchQueue.main.async {
                if authorized {
                    self?.showScreenAPI(withImportedDocument: nil)
                } else {
                    self?.showCameraPermissionDeniedError()
                }
            }
        }
    }
    
    func main(viewController: MainViewController, didTapShowHelp: ()) {
        showHelpViewController()
    }
    
}

// MARK: HelpCoordinatorDelegate

extension AppCoordinator: HelpCoordinatorDelegate {
    func help(coordinator: HelpCoordinator, didFinish: ()) {
        appNavigationController.popViewController(animated: true)
        remove(childCoordinator: coordinator)
    }
}


extension AppCoordinator: PDFNoResultsViewControllerDelegate {
    func pdfNoResults(viewController: PDFNoResultsViewController, didTapStartOver: ()) {
    }
}
// MARK: ScreenAPICoordinatorDelegate

extension AppCoordinator: ScreenAPICoordinatorDelegate {
    
    func screenAPI(coordinator: ScreenAPICoordinator, didCancel: ()) {
        appNavigationController.popToRootViewController(animated: true)
        remove(childCoordinator: coordinator)
    }
    
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ()) {
        let help = HelpViewController(nibName: nil, bundle: nil)
        appNavigationController.setViewControllers([help], animated: true)
        remove(childCoordinator: coordinator)
    }
}

