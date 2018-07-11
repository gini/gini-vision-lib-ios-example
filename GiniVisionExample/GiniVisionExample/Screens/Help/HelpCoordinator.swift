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
        return ContainerNavigationController(rootViewController: navigationController)
    }
    var childCoordinators: [Coordinator] = []
    let theme: Theme
    
    lazy var navigationController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.helpViewController)
        nav.apply(theme)
        if #available(iOS 11.0, *) {
            nav.navigationBar.largeTitleTextAttributes = nav.navigationBar.titleTextAttributes
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
    
    init(theme: Theme) {
        self.theme = theme
    }
    
    func loadWebView(withLink link: HelpLink) {
        if let itemUrl = link.url {
            guard let webViewController = webViewController else {
                self.webViewController = WebViewController(title: link.title,
                                                      url: itemUrl)
                navigationController.pushViewController(self.webViewController!, animated: true)
                return
            }
            webViewController.title = link.title
            webViewController.url = itemUrl
            webViewController.webView.load(URLRequest(url: itemUrl))
            
            navigationController.pushViewController(webViewController, animated: true)
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
