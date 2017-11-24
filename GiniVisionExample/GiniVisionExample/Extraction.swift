//
//  Extraction.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/24/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import Gini_iOS_SDK

struct Extraction {
    
    let key: String
    let name: String
    var value: String
    
    static let realNames: [String: String] = ["paymentRecipient": "Payment Recipient"]
    
    init(key: String, name: String, value: String) {
        self.key = key
        self.name = name
        self.value = value
    }
    
    init(giniExtraction: GINIExtraction) {
        let name = Extraction.realNames[giniExtraction.name] ?? giniExtraction.name.uppercased()
        self.init(key: giniExtraction.name, name: name, value: giniExtraction.value)
    }

}
