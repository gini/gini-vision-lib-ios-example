//
//  AppCoordinator.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import GiniVision
import Gini

final class AppCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    let application: UIApplication
    let theme: Theme
    let transition = HelpTransitionAnimator()
    var documentAnalysisHelper: DocumentAnalysisHelper?
    var selectedAPIDomain: APIDomain = .default

    var client: Client {
        let credentials = CredentialsHelper.fetchCredentials()
        let clientId = credentials.id ?? ""
        let clientSecret = credentials.password ?? ""
        let domain = "giniexample.com"
        
        return Client(id: clientId,
                      secret: clientSecret,
                      domain: domain)
    }
    
    var rootViewController: UIViewController {
        return appNavigationController
    }
    
    lazy var appNavigationController: UINavigationController = {
        let navController = RootNavigationController(rootViewController: self.mainViewController)
        navController.isNavigationBarHidden = true
        navController.apply(theme)
        navController.delegate = self
        return navController
    }()
    
    lazy var mainViewController: MainViewController = {
        let mainViewController = MainViewController(theme: theme)
        mainViewController.delegate = self
        return mainViewController
    }()
    
    lazy var giniConfiguration: GiniConfiguration = {
        let configuration = GiniConfiguration()
        configuration.fileImportSupportedTypes = .pdf_and_images
        configuration.openWithEnabled = true
        configuration.navigationBarItemTintColor = theme.secondaryColor
        configuration.navigationBarTintColor = theme.primaryColor
        configuration.navigationBarTitleColor = theme.secondaryColor
        configuration.qrCodeScanningEnabled = true
        configuration.galleryPickerItemSelectedBackgroundCheckColor = theme.primaryColor
        configuration.multipagePageIndicatorColor = theme.primaryColor
        configuration.multipageToolbarItemsColor = theme.primaryColor
        configuration.noResultsBottomButtonColor = theme.buttonsColor
        configuration.stepIndicatorColor = theme.primaryColor
        configuration.imagesStackIndicatorLabelTextcolor = theme.primaryColor
        configuration.statusBarStyle = theme.statusBarStyle
        configuration.flashToggleEnabled = true
        
        return configuration
    }()
    
    var resultViewController: ResultsViewController?
    var pdfNoResultsViewController: PDFNoResultsViewController {
        let noResults = PDFNoResultsViewController(nibName: nil, bundle: nil)
        noResults.delegate = self
        return noResults
    }
    
    init(window: UIWindow, application: UIApplication) {
        self.window = window
        self.application = application
        self.theme = Theme(infoDictionary: Bundle.main.infoDictionary ?? [:])
    }
    
    func start() {
        showMainViewController()
    }
    
    func processExternalDocument(withUrl url: URL, sourceApplication: String?) {
        let data = try? Data(contentsOf: url)
        
        let documentBuilder = GiniVisionDocumentBuilder(data: data, documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        guard let document = documentBuilder.build() else { return }
        
        
        // When a document is imported with "Open with", a dialog allowing to choose between both APIs
        // is shown in the main screen. Therefore it needs to go to the main screen if it is not there yet.
        popToRootViewControllerIfNeeded()
        
        do {
            try GiniVisionDocumentValidator.validate(document, withConfig: giniConfiguration)
            showScreenAPI(withImportedDocument: document)
        } catch let error {
            showExternalDocumentNotValidDialog(forError: error)
        }
    }
    
}

// MARK: - Fileprivate

fileprivate extension AppCoordinator {
    func popToRootViewControllerIfNeeded() {
        self.appNavigationController.popToRootViewController(animated: true)
        self.childCoordinators.forEach(remove)
    }
    
    func showMainViewController() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func showHelpViewController() {
        let helpCoordinator = HelpCoordinator(theme: theme, selectedAPIDomain: selectedAPIDomain)
        helpCoordinator.delegate = self
        add(childCoordinator: helpCoordinator)
        appNavigationController.pushViewController(helpCoordinator.rootViewController, animated: true)
    }
    
    func showScreenAPI(withImportedDocument importedDocument: GiniVisionDocument?) {
        self.documentAnalysisHelper = selectedAPIDomain == .default ?
            DefaultDocumenAnalysisHelper(client: client) :
            AccountingDocumentAnalysisHelper(client: client)
        giniConfiguration.multipageEnabled = selectedAPIDomain == .default
        
        let screenAPICoordinator = ScreenAPICoordinator(importedDocument: importedDocument,
                                                        documentAnalysisHelper: documentAnalysisHelper!,
                                                        giniConfiguration: giniConfiguration)
        screenAPICoordinator.delegate = self
        add(childCoordinator: screenAPICoordinator)
        appNavigationController.pushViewController(screenAPICoordinator.rootViewController, animated: true)
    }
    
    func checkCameraPermissions(completion: @escaping (Bool) -> Void) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { authorized in
                completion(authorized)
            }
        }
    }
    
    func showCameraPermissionDeniedError() {
        let alertMessage = NSLocalizedString("camera.permissions.denied.title",
                                             comment: "camera permissions denied message title")
        let cancelTitle = NSLocalizedString("cancel",
                                            comment: "camera permissions cancel option title")
        let grantAccessTitle = NSLocalizedString("camera.permissions.denied.granpermissions.button",
                                                 comment: "camera permissions gran access option title")
        let alertViewController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        }))
        
        alertViewController.addAction(UIAlertAction(title: grantAccessTitle,
                                                    style: .default, handler: { [weak self] _ in
                                                        alertViewController.dismiss(animated: true, completion: nil)
                                                        self?.application.openAppSettings()
        }))
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    func showExternalDocumentNotValidDialog(forError error: Error) {
        let title = NSLocalizedString("notvalid.document.title", comment: "alert title when document invalid")
        let message: String = {
            if let documentError = error as? DocumentValidationError {
                switch documentError {
                case .exceededMaxFileSize:
                    return NSLocalizedString("notvalid.document.toolarge",
                                             comment: "alert message when document size is too large")
                case .fileFormatNotValid:
                    return NSLocalizedString("notvalid.document.typenotsupported",
                                             comment: "alert message when document type invalid")
                case .imageFormatNotValid:
                    return NSLocalizedString("notvalid.document.typenotsupported",
                                             comment: "alert message when image document type invalid")
                case .pdfPageLengthExceeded:
                    return NSLocalizedString("notvalid.document.toomanypages",
                                             comment: "alert message when PDF document excedeeds 10 pages")
                default:
                    return NSLocalizedString("notvalid.document.generic",
                                             comment: "alert message when document invalid")
                }
            } else {
                return NSLocalizedString("notvalid.document.generic",
                                         comment: "alert message when document invalid")
            }
        }()
        
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        })
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
}

// MARK: UINavigationControllerDelegate

extension AppCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let helpFromVC = (fromVC as? ContainerNavigationController)?
            .rootViewController.viewControllers.first as? HelpViewController
        let helpToVC = (toVC as? ContainerNavigationController)?
            .rootViewController.viewControllers.first as? HelpViewController
        
        if helpFromVC != nil || helpToVC != nil {
            transition.operation = operation
            transition.originPoint = mainViewController.helpButton.center
            return transition
        }
        
        if toVC is MainViewController {
            appNavigationController.isNavigationBarHidden = true
        }
        
        return nil
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
    func help(coordinator: HelpCoordinator, didFinish apiDomain: APIDomain) {
        selectedAPIDomain = apiDomain
        appNavigationController.popViewController(animated: true)
        remove(childCoordinator: coordinator)
    }
}

// MARK: PDFNoResultsViewControllerDelegate

extension AppCoordinator: PDFNoResultsViewControllerDelegate {
    func pdfNoResults(viewController: PDFNoResultsViewController, didTapStartOver: ()) {
        appNavigationController.popToRootViewController(animated: true)
    }
}

// MARK: ResultsViewControllerDelegate

extension AppCoordinator: ResultsViewControllerDelegate {
    
    func resultViewController(with results: [Extraction]) -> ResultsViewController {
        let resultViewController = ResultsViewController(model:
            ResultsViewModel(documentAnalysisHelper: documentAnalysisHelper!,
                             results: results), theme: theme)
        resultViewController.delegate = self
        return resultViewController
    }
    
    func results(viewController: ResultsViewController, didTapDone: ()) {
        documentAnalysisHelper?.resetToInitialState()
        appNavigationController.popToRootViewController(animated: true)
    }
}

// MARK: ScreenAPICoordinatorDelegate

extension AppCoordinator: ScreenAPICoordinatorDelegate {
    
    func screenAPI(coordinator: ScreenAPICoordinator, didCancel: ()) {
        appNavigationController.popToRootViewController(animated: true)
        remove(childCoordinator: coordinator)
    }
    
    func screenAPI(coordinator: ScreenAPICoordinator, didFinishWithResults results: [Extraction]) {
        var viewControllers = appNavigationController.viewControllers.filter { $0 is MainViewController}
        
        let hasExtractions = {
            return results.filter { documentAnalysisHelper!.pay5Parameters.contains($0.name ?? "no-name") }.count > 0
        }()
        
        let viewController = hasExtractions ? resultViewController(with: results) : pdfNoResultsViewController
        viewControllers.append(viewController)
        appNavigationController.setViewControllers(viewControllers, animated: true)
        appNavigationController.isNavigationBarHidden = false
        remove(childCoordinator: coordinator)
    }
}

