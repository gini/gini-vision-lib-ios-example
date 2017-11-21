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
}

// MARK: MainViewControllerDelegate

extension AppCoordinator: MainViewControllerDelegate {
    
    func main(viewController: MainViewController, didTapStartAnalysis: ()) {
        
    }
    
    func main(viewController: MainViewController, didTapShowHelp: ()) {
        
    }
    
}