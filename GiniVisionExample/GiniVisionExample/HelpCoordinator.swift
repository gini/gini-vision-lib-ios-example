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

final class HelpCoordinator: NSObject, Coordinator {
    
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
    
    var webViewController: WebViewController?
    
    func loadWebView(withLink link: HelpLink) {
        if let itemUrl = link.url {
            if let webViewController = webViewController {
                webViewController.title = link.title
                webViewController.url = itemUrl
                webViewController.webView.load(URLRequest(url: itemUrl))
            } else {
                webViewController = WebViewController(title: link.title, url: itemUrl)
            }
            navigationController.pushViewController(webViewController!, animated: true)
        }
    }
}

// MARK: HelpViewControllerDelegate

extension HelpCoordinator: HelpViewControllerDelegate {
    func help(viewController: HelpViewController, didTapClose: ()) {
        delegate?.help(coordinator: self, didFinish: ())
    }
    
    func help(viewController: HelpViewController, didSelectLink link: HelpLink) {
        loadWebView(withLink: link)
    }
    
}
