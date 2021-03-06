//
//  ContainerNavigationController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/28/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

final class ContainerNavigationController: UIViewController {
    
    var rootViewController: UINavigationController
    
    override var shouldAutorotate: Bool {
        return rootViewController.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return rootViewController.supportedInterfaceOrientations
    }
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(rootViewController)
        view.addSubview(rootViewController.view)
        rootViewController.willMove(toParent: self)
        rootViewController.didMove(toParent: self)        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootViewController.view.frame = self.view.bounds
    }
}
