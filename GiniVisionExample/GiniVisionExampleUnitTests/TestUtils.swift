//
//  TestUtils.swift
//  GiniVisionExampleUnitTests
//
//  Created by Enrique del Pozo Gómez on 11/29/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import XCTest

extension XCTestCase {
    func urlFromImage(named: String, fileExtension: String) -> URL? {
        let testBundle = Bundle(for: type(of: self))
        return testBundle.url(forResource: named, withExtension: fileExtension)
    }
}

