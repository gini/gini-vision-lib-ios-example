//
//  HelpCoordinator.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/22/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

protocol HelpCoordinatorDelegate: class {
    func help(coordinator: HelpCoordinator, didFinish: ())
}

final class HelpCoordinator: Coordinator {
    
    weak var delegate: HelpCoordinatorDelegate?
    var rootViewController: UIViewController {
        return navigationController
    }
    var childCoordinators: [Coordinator] = []
    
    lazy var navigationController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.helpViewController)
        nav.navigationBar.barTintColor = .giniBlue
        nav.navigationBar.tintColor = .white
        var attributes = nav.navigationBar.titleTextAttributes ?? [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.white
        nav.navigationBar.titleTextAttributes = attributes
        
        if #available(iOS 11.0, *) {
            nav.navigationBar.largeTitleTextAttributes = attributes
            nav.navigationBar.prefersLargeTitles = true
        }
        return nav
    }()
    
    lazy var helpViewController: HelpViewController = {
        var helpViewController = HelpViewController()
        helpViewController.delegate = self
        return helpViewController
    }()
}

// MARK: HelpViewControllerDelegate

extension HelpCoordinator: HelpViewControllerDelegate {
    func help(viewController: HelpViewController, didTapClose: ()) {
        delegate?.help(coordinator: self, didFinish: ())
    }
    
    func help(viewController: HelpViewController, didSelectItem item: HelpLink) {
        print(item)
    }
    
}
