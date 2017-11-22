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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let nav = UINavigationController(rootViewController: HelpViewController(nibName: nil, bundle: nil))
            nav.navigationBar.barTintColor = .giniBlue
            nav.navigationBar.tintColor = .white
            var attributes = nav.navigationBar.titleTextAttributes ?? [String: AnyObject]()
            attributes[NSForegroundColorAttributeName] = UIColor.white
            nav.navigationBar.titleTextAttributes = attributes
            
            if #available(iOS 11.0, *) {
                nav.navigationBar.largeTitleTextAttributes = attributes
                nav.navigationBar.prefersLargeTitles = true
            }
            self.rootViewController.present(nav, animated: true, completion: nil)
        }
    }
}

// MARK: MainViewControllerDelegate

extension AppCoordinator: MainViewControllerDelegate {
    
    func main(viewController: MainViewController, didTapStartAnalysis: ()) {
        
    }
    
    func main(viewController: MainViewController, didTapShowHelp: ()) {
        
    }
    
}