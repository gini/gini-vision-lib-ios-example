//
//  ExtractionTests.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/24/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest
@testable import GiniVisionExample
@testable import Gini_iOS_SDK

final class ExtractionTests: XCTestCase {
    
    var extraction: Extraction!
    var giniExtraction = GINIExtraction(name: "paymentRecipient",
                                        value: "extractionValue",
                                        entity: "extractionValue", box: [:])!
    
    override func setUp() {
        super.setUp()
        extraction = Extraction(giniExtraction: giniExtraction)
    }
    
    func testInitializationWithGiniExtraction() {
        XCTAssertEqual(extraction.key, "paymentRecipient",
                       "extraction key should match with the one in gini extraction")
        XCTAssertEqual(extraction.value, "extractionValue",
                       "extraction value should match with the one in gini extraction")
        XCTAssertEqual(extraction.name, "Payment Recipient", "extraction name should match")
    }
    
    func testNotMatchingName() {
        let giniExtraction = GINIExtraction(name: "not matching key",
                                            value: "extractionValue",
                                            entity: "extractionValue", box: [:])!
        extraction = Extraction(giniExtraction: giniExtraction)

        XCTAssertEqual(extraction.name, "not matching key".uppercased(),
                       "extraction name should be key uppercased when there is not matching")
    }
    
}
