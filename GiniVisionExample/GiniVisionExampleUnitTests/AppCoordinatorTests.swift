//
//  AppCoordinatorTests.swift
//  GiniVisionExampleTests
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
import AVFoundation
@testable import GiniVisionExample
@testable import Gini

final class AppCoordinatorTests: XCTestCase {
    
    var appCoordinator: AppCoordinator!
    
    override func setUp() {
        super.setUp()
        appCoordinator = AppCoordinator(window: UIWindow(frame: UIScreen.main.bounds),
                                        application: UIApplication.shared)
    }
    
    func testInitialization() {
        XCTAssertTrue(appCoordinator.childCoordinators.isEmpty,
                      "child coordinators array should be empty after initialization")
        XCTAssertNotNil(appCoordinator.window, "window should not be nil after after initialization")
    }
    
    func testWindowRootViewControllerAfterStart() {
        appCoordinator.start()
        XCTAssertNotNil(appCoordinator.window.rootViewController,
                        "window should have a rootviewcontroller after starting app")
    }
    
    func testMainViewControllerDelegateAfterStart() {
        appCoordinator.start()
        XCTAssertNotNil(appCoordinator.mainViewController.delegate as? AppCoordinator,
                        "main view controller delegate should be an instance of AppCoordinator")
    }
    
    func testNavigationControllerDelegate() {
        appCoordinator.start()
        XCTAssertNotNil(appCoordinator.appNavigationController.delegate as? AppCoordinator,
                        "app navigation view controller delegate should be an instance of AppCoordinator")
    }
    
    func testChildCoordinatorCountWhenHelpShown() {
        appCoordinator.start()
        appCoordinator.main(viewController: appCoordinator.mainViewController, didTapShowHelp: ())
        
        XCTAssertFalse(appCoordinator.childCoordinators.isEmpty,
                       "child coordinators count should not be 0 after showing help")
    }
    
    func testHelpCoordinatorDelegateAfterShowHelp() {
        appCoordinator.start()
        appCoordinator.main(viewController: appCoordinator.mainViewController, didTapShowHelp: ())
        
        let helpCoordinator = appCoordinator.childCoordinators.compactMap {$0 as? HelpCoordinator}.first!
        
        XCTAssertNotNil(helpCoordinator.delegate as? AppCoordinator,
                        "help view controller delegate should be an instance of AppCoordinator")
    }
    
    func testChildCoordinatorCountAfterDismissHelp() {
        appCoordinator.start()
        appCoordinator.main(viewController: appCoordinator.mainViewController, didTapShowHelp: ())
        
        appCoordinator.help(coordinator: childCoordinator(ofType: HelpCoordinator.self)!, didFinish: .default)
        
        XCTAssertNil(childCoordinator(ofType: HelpCoordinator.self),
                     "help coordinator should not longer exist after dismiss help view controller")
    }
    
    func testPDFNoResultsViewControllerDelegateAfterInitialization() {
        appCoordinator.main(viewController: appCoordinator.mainViewController, didTapStartAnalysis: ())
        
        XCTAssertNotNil(appCoordinator.pdfNoResultsViewController.delegate as? AppCoordinator,
                        "pdf no results view controller should be an instance of AppCoordinator")
    }
    
    func testHelpAnimationWhenShowHelp() {
        appCoordinator.start()
        _ = appCoordinator.mainViewController.view
        appCoordinator.main(viewController: appCoordinator.mainViewController, didTapShowHelp: ())
        let helpViewController = childCoordinator(ofType: HelpCoordinator.self)!.rootViewController
        let animatorPush = appCoordinator.navigationController(appCoordinator.appNavigationController,
                                                               animationControllerFor: .push,
                                                               from: appCoordinator.mainViewController,
                                                               to: helpViewController)
        let animatorPop = appCoordinator.navigationController(appCoordinator.appNavigationController,
                                                              animationControllerFor: .pop,
                                                              from: helpViewController,
                                                              to: appCoordinator.mainViewController)
        
        XCTAssertNotNil(animatorPush as? HelpTransitionAnimator,
                        "the animator should be an instance of HelpTransitionAnimator when pushing")
        XCTAssertNotNil(animatorPop as? HelpTransitionAnimator,
                        "the animator should be an instance of HelpTransitionAnimator when poping")
    }
    
    fileprivate func childCoordinator<T>(ofType: T.Type) -> T? {
        return appCoordinator.childCoordinators.compactMap {$0 as? T}.first
    }
}
