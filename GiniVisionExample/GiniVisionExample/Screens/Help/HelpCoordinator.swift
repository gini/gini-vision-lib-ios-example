//
//  HelpCoordinator.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/22/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit
import Gini

protocol HelpCoordinatorDelegate: AnyObject {
    func help(coordinator: HelpCoordinator, didFinish apiDomain: APIDomain)
}

final class HelpCoordinator: NSObject, Coordinator {
    
    weak var delegate: HelpCoordinatorDelegate?
    var rootViewController: UIViewController {
        return ContainerNavigationController(rootViewController: navigationController)
    }
    var childCoordinators: [Coordinator] = []
    var selectedAPIDomain: APIDomain
    let theme: Theme
    
    lazy var navigationController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.helpViewController)
        nav.apply(theme)
        if #available(iOS 11.0, *) {
            nav.navigationBar.prefersLargeTitles = true
        }
        return nav
    }()
    
    lazy var helpViewController: HelpViewController = {
        var helpViewController = HelpViewController(selectedAPIDomain: selectedAPIDomain)
        helpViewController.delegate = self
        return helpViewController
    }()
    
    var webViewController: WebViewController?
    
    init(theme: Theme, selectedAPIDomain: APIDomain) {
        self.theme = theme
        self.selectedAPIDomain = selectedAPIDomain
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
        delegate?.help(coordinator: self, didFinish: viewController.selectedAPIDomain)
    }
    
    func help(viewController: HelpViewController, didSelectLink link: HelpLink) {
        loadWebView(withLink: link)
    }
    
}
