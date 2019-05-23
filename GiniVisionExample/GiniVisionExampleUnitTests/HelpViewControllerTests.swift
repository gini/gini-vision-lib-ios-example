//
//  HelpViewControllerTests.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/22/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample

class HelpViewControllerTests: XCTestCase {
    
    let helpViewController = HelpViewController(selectedAPIDomain: .default)
    let versions: [HelpKeyValueItem] = [("GVL Version", "3.2.1"), ("App version", "0.0.1"), ("Test version", "1.0.1")]
    let links: [HelpLink] = [("GVL Changelog",
                              URL(string: "http://developer.gini.net/gini-vision-lib-ios/docs/changelog.html"))]
    
    lazy var sections: [(title: String, items: [Any])] = [("Version", self.versions), ("Links", self.links),
                                                          ("Version2", self.versions), ("Links2", self.links)]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testTableViewDatasource() {
        _ = helpViewController.view
        XCTAssertNotNil(helpViewController.tableView.dataSource as? HelpViewController,
                        "table datasource should be an instance of HelpViewController")
    }
    
    func testTableViewDelegate() {
        _ = helpViewController.view
        XCTAssertNotNil(helpViewController.tableView.delegate as? HelpViewController,
                        "table delegate should be an instance of HelpViewController")
    }
    
    func testTableViewSectionCount() {
        helpViewController.sections = sections
        _ = helpViewController.view
        XCTAssertEqual(helpViewController.numberOfSections(in: helpViewController.tableView), 4,
                       "table view sections count should be 4")
    }
    
    func testTableViewSection0ItemsCount() {
        helpViewController.sections = sections
        _ = helpViewController.view
        XCTAssertEqual(helpViewController.tableView(helpViewController.tableView,
                                                    numberOfRowsInSection: 0), 3,
                       "table view sections count should be 4")
    }
    
    func testTableViewSection0HeaderTitle() {
        helpViewController.sections = sections
        _ = helpViewController.view
        XCTAssertEqual(helpViewController.tableView(helpViewController.tableView,
                                                    titleForHeaderInSection: 0),
                       "Version",
                       "table view section 0 title should be Version")
    }
    
    func testTableViewHelpVersionCell() {
        helpViewController.sections = sections
        _ = helpViewController.view
        let indexPath = IndexPath(row: 0, section: 0) // HelpVersion
        
        let cell = helpViewController.tableView(helpViewController.tableView,
                                                cellForRowAt: indexPath)
        XCTAssertEqual(cell.textLabel?.text, "GVL Version", "cell text label is not first item in section 0 title")
        XCTAssertEqual(cell.detailTextLabel?.text, "3.2.1",
        "cell detailed text label is not first item in section 0 version")
        XCTAssertEqual(cell.accessoryType, .none, "a help version cell should not have an accessory type")
    }
    
    func testTableViewHelpLinkCell() {
        helpViewController.sections = sections
        _ = helpViewController.view
        let indexPath = IndexPath(row: 0, section: 1) // HelpVersion
        
        let cell = helpViewController.tableView(helpViewController.tableView,
                                                cellForRowAt: indexPath)
        XCTAssertEqual(cell.textLabel?.text, "GVL Changelog", "cell text label is not first item in section 1 title")
        XCTAssertNil(cell.detailTextLabel, "cell detailed text label should be nil")
        XCTAssertEqual(cell.accessoryType, .disclosureIndicator,
                       "a help version cell should have a disclosureIndicator accessory type")
    }
}
