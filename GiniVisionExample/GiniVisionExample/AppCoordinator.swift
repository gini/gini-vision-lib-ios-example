//
//  AppCoordinator.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import UIKit

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
