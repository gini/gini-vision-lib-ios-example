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
    
    lazy var mainViewController: MainViewController = {
        let mainViewController = MainViewController(nibName: nil, bundle: nil)
        mainViewController.delegate = self
        return mainViewController
    }()
    
    var resultViewController: ResultsViewController?
    
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
    
    @discardableResult func showResultsViewController(withResult result: [String: GINIExtraction])
        -> ResultsViewController {
            resultViewController = ResultsViewController(model: ResultsViewModel(result: result))
            resultViewController!.delegate = self
            rootViewController.present(resultViewController!, animated: true, completion: nil)
            return resultViewController!
    }
}
// TODO: Move to screen api coordinator when implemented
extension AppCoordinator: ResultsViewControllerDelegate {
    func results(viewController: ResultsViewController, didTapDone: ()) {
        resultViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: MainViewControllerDelegate

extension AppCoordinator: MainViewControllerDelegate {
    
    func main(viewController: MainViewController, didTapStartAnalysis: ()) {
        let extraction = GINIExtraction(name: "name", value: "value", entity: "entity", box: [:])
        let result: [String: GINIExtraction] = ["first extraction": extraction!]
        showResultsViewController(withResult: result)
    }
    
    func main(viewController: MainViewController, didTapShowHelp: ()) {
        
    }
    
}
