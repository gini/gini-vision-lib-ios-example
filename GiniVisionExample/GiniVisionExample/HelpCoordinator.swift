//
//  HelpCoordinator.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/22/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

protocol HelpCoordinatorDelegate: class {
    func help(coordinator: HelpCoordinator, didTapClose: ())
}

final class HelpCoordinator: Coordinator {
    
    weak var delegate: HelpCoordinatorDelegate?
    var rootViewController: UIViewController {
        return HelpViewController()
    }
    var childCoordinators: [Coordinator] = []
    
    lazy var helpViewController: UINavigationController = {
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
        return nav
    }()
    
}
