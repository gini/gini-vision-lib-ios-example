//
//  PDFNoResultsViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/24/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

protocol PDFNoResultsViewControllerDelegate: class {
    func pdfNoResults(viewController: PDFNoResultsViewController, didTapStartOver: ())
}

final class PDFNoResultsViewController: UIViewController {

    weak var delegate: PDFNoResultsViewControllerDelegate?
    
    @IBAction func startOver(_ sender: Any) {
        delegate?.pdfNoResults(viewController: self, didTapStartOver: ())
    }
}
