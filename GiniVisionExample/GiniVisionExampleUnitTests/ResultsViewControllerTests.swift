//
//  ResultsViewControllerTests.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
import Gini_iOS_SDK
@testable import GiniVisionExample

final class ResultsViewControllerTests: XCTestCase {
    
    var resultsViewController: ResultsViewController!
    var resultsViewModel: ResultsViewModelMock!
    var results: ExtractionCollection = [("Section 0", [Extraction(key: "item 1", name: "value 1", value: "id 1"),
                                                        Extraction(key: "item 2", name: "value 2", value: "id 2")])]
    
    override func setUp() {
        super.setUp()
        resultsViewModel = ResultsViewModelMock(documentService: DocumentServiceMock(), results: [:])
        resultsViewController = ResultsViewController(model: resultsViewModel, theme: Theme(infoDictionary: [:]))
    }
    
    func testInitialization() {
        XCTAssertNotNil(resultsViewController.model, "model should not be nil on initialization")
    }
    
    func testTableViewDatasource() {
        _ = resultsViewController.view
        XCTAssertNotNil(resultsViewController.tableView.dataSource as? ResultsViewController,
                        "table view datasource should be an instance of ResultsViewController")
    }
    
    func testNumberOfSections() {
        resultsViewController.model.extractions = results
        _ = resultsViewController.view
        XCTAssertEqual(results.count, resultsViewController.numberOfSections(in: resultsViewController.tableView),
                       "sections count should match to results array")
    }
    
    func testRowsInSection0() {
        resultsViewController.model.extractions = results
        _ = resultsViewController.view
        XCTAssertEqual(results[0].items.count,
                       resultsViewController.tableView(resultsViewController.tableView, numberOfRowsInSection: 0),
                       "sections count should match to results array")
    }
    
    func testResultsTableCellIsRegistered() {
        _ = resultsViewController.view
        XCTAssertNotNil(resultsViewController.tableView.dequeueReusableCell(withIdentifier:
            resultsViewController.resultsTableCellIdentifier) as? ResultsTableViewCell,
                        "cell should be registered and be an instance of ResultsTableViewCell")
    }
    
    func testResultsTableCell() {
        resultsViewController.model.extractions = results
        _ = resultsViewController.view
        let indexPath = IndexPath(row: 0, section: 0)

        let cell = resultsViewController.tableView(resultsViewController.tableView,
                                                   cellForRowAt: indexPath) as? ResultsTableViewCell
        
        XCTAssertEqual(cell?.fieldName.text, results[indexPath.section].items[indexPath.row].name,
                       "field name should match")
        XCTAssertEqual(cell?.fieldValue.text, results[indexPath.section].items[indexPath.row].value,
                       "field value should match")
        XCTAssertNotNil(cell?.indexPath, "indexPath reference should not be nil")

    }
    
    func testResultsTableCellTextFieldDelegate() {
        resultsViewController.model.extractions = results
        _ = resultsViewController.view
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = resultsViewController.tableView(resultsViewController.tableView,
                                                   cellForRowAt: indexPath) as? ResultsTableViewCell
        
        XCTAssertNotNil(cell?.delegate as? ResultsViewController,
                        "cell delegate should be an instance of ResultsViewController")
    }
    
    func testResultsValueChangeAfterEditIt() {
        resultsViewController.model.extractions = results
        _ = resultsViewController.view
        let indexPath = IndexPath(row: 0, section: 0)
        let item = results[indexPath.section].items[indexPath.row]
        let cell = resultsViewController.tableView(resultsViewController.tableView,
                                                   cellForRowAt: indexPath) as? ResultsTableViewCell
        cell?.fieldValue.text = "New value"
        cell?.fieldValue.sendActions(for: .editingChanged)
        
        let itemModified = resultsViewController.model.extractions[indexPath.section].items[indexPath.row]
        
        XCTAssertNotEqual(item.value, itemModified.value, "item value should have changed after edit it")
    }
    
    func testSendFeedBackOnDone() {
        _ = resultsViewController.view
        resultsViewController.done(())
        
        XCTAssertTrue(resultsViewModel.feedBackSent, "feedback should be sent when done button is triggered")
    }
    
}
