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
    
    static let realNames: [String: String] = [
        "amountToPay": "Amount",
        "paymentRecipient": "Payment Recipient",
        "paymentReference": "Payment Reference",
        "senderName": "Sender name",
        "senderCity": "Sender city",
        "senderStreet": "Sender street",
        "senderPostalCode": "Sender postal code",
        "senderNameAddition": "Sender name addition",
        "senderPoBox": "Sender po box",
        "invoiceId": "Invoice ID",
        "docType": "Document type",
        "paymentState": "Payment state",
        "documentDate": "Document date",
        "documentDomain": "Document domain",
        "companyRegisterId": "Company register ID",
        "bankAccountNumber": "Bank account number",
        "bankNumber": "Bank number",
        "customerId": "Customer ID",
        "email": "Email",
        "paymentDueDate": "Payment due date",
        "paymentPurpose": "Payment purpose",
        "phoneNumber": "Phone number",
        "taxNumber": "Tax number",
        "vatRegNumber": "VAT Reg Number",
        "website": "Website"
    ]
    
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
