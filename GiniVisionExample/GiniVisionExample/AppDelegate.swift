//
//  AppDelegate.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/20/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        appCoordinator = AppCoordinator(window: UIWindow(frame: UIScreen.main.bounds), application: application)
        appCoordinator.start()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        appCoordinator.processExternalDocument(withUrl: url, sourceApplication: sourceApplication)
        return true
    }

}
