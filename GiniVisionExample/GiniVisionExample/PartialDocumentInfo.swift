//
//  PartialDocumentInfo.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 5/3/18.
//

import Gini

struct PartialDocumentInfo {
    var info: Gini.PartialDocumentInfo
    var document: Document?
    var order: Int
}

extension PartialDocumentInfo: Comparable {
    static func == (lhs: PartialDocumentInfo, rhs: PartialDocumentInfo) -> Bool {
        return lhs.info.document == rhs.info.document
    }
    
    static func < (lhs: PartialDocumentInfo, rhs: PartialDocumentInfo) -> Bool {
        return lhs.order < rhs.order
    }
}
