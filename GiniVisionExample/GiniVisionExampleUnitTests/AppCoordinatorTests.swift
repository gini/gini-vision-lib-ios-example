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
@testable import Gini_iOS_SDK

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
        
        let helpCoordinator = appCoordinator.childCoordinators.flatMap {$0 as? HelpCoordinator}.first!
        
        XCTAssertNotNil(helpCoordinator.delegate as? AppCoordinator,
                        "help view controller delegate should be an instance of AppCoordinator")
    }
    
    func testChildCoordinatorCountAfterDismissHelp() {
        appCoordinator.start()
        appCoordinator.main(viewController: appCoordinator.mainViewController, didTapShowHelp: ())

        appCoordinator.help(coordinator: childCoordinator(ofType: HelpCoordinator.self)!, didFinish: ())
        
        XCTAssertNil(childCoordinator(ofType: HelpCoordinator.self),
                     "help coordinator should not longer exist after dismiss help view controller")
    }
    
    fileprivate func childCoordinator<T>(ofType: T.Type) -> T? {
        return appCoordinator.childCoordinators.flatMap {$0 as? T}.first
    }
    
    func testPDFNoResultsViewControllerDelegateAfterInitialization() {
        appCoordinator.main(viewController: appCoordinator.mainViewController, didTapStartAnalysis: ())
        
        XCTAssertNotNil(appCoordinator.pdfNoResultsViewController.delegate as? AppCoordinator,
                        "pdf no results view controller should be an instance of AppCoordinator")
    }
    
    func testResultsViewControllerDelegate() {
        let result: [String: GINIExtraction] = ["first extraction": GINIExtraction(name: "name",
                                                                                   value: "value",
                                                                                   entity: "entity",
                                                                                   box: [:])!]
        appCoordinator.documentService.result = result
        let resultsViewController = appCoordinator.resultViewController!
        XCTAssertNotNil(resultsViewController.delegate as? AppCoordinator,
                       "resultsViewController delegate should be an instance of AppCoordinator")
    }
    
    func testScreenAPICoordinatorDelegateAfterStartAnalysis() {
        appCoordinator.start()
        appCoordinator.main(viewController: appCoordinator.mainViewController, didTapStartAnalysis: ())
        let screenAPICoordinator = appCoordinator.childCoordinators.flatMap { $0 as? ScreenAPICoordinator }.first
        XCTAssertNotNil(screenAPICoordinator, "screenAPICoordinator should not be nil after start analysis")
        XCTAssertNotNil(screenAPICoordinator!.delegate as? AppCoordinator)
    }
    
    func testOpenWithImport() {
        let url = urlFromImage(named: "invoice", fileExtension: "jpg")!
        appCoordinator.processExternalDocument(withUrl: url, sourceApplication: "testTarget")
        
        let screenAPICoordinator = appCoordinator.childCoordinators.flatMap { $0 as? ScreenAPICoordinator }.first
        XCTAssertNotNil(screenAPICoordinator, "screenAPICoordinator should not be nil after import file")
        
    }
    
    fileprivate func urlFromImage(named: String, fileExtension: String) -> URL? {
        let testBundle = Bundle(for: type(of: self))
        return testBundle.url(forResource: named, withExtension: fileExtension)
    }
    
    fileprivate func childCoordinator<T>(ofType: T.Type) -> T? {
        return appCoordinator.childCoordinators.flatMap {$0 as? T}.first
    }
}
