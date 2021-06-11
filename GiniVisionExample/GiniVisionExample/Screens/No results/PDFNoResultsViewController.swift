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
    
    @IBOutlet weak var firstTipImage: UIButton! {
        didSet {
            firstTipImage.layer.cornerRadius = firstTipImage.frame.width / 2
        }
    }
    @IBOutlet weak var secondTipImage: UIButton! {
        didSet {
            secondTipImage.layer.cornerRadius = secondTipImage.frame.width / 2
        }
    }
    @IBOutlet weak var thirdTipImage: UIButton! {
        didSet {
            thirdTipImage.layer.cornerRadius = thirdTipImage.frame.width / 2
        }
    }
    
    @IBOutlet weak var startOverButton: UIButton! {
        didSet {
            startOverButton.layer.shadowColor = UIColor.black.cgColor
            startOverButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            startOverButton.layer.shadowRadius = 2
            startOverButton.layer.shadowOpacity = 0.2
            startOverButton.layer.masksToBounds = false
            startOverButton.setTitle(NSLocalizedString("start.analysis.button",
                                                     comment: "start anysis button on main screen"), for: .normal)
        }
    }
    
    weak var delegate: PDFNoResultsViewControllerDelegate?
    
    @IBAction func startOver(_ sender: Any) {
        delegate?.pdfNoResults(viewController: self, didTapStartOver: ())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("noresults.pdf.screen.title", comment: "title for pdf no results screen")
    }
}
