//
//  MainViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/20/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate: class {
    func main(viewController: MainViewController, didTapStartAnalysis: ())
    func main(viewController: MainViewController, didTapShowHelp: ())
}

final class MainViewController: UIViewController {

    weak var delegate: MainViewControllerDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func startAnalysis(_ sender: Any) {
        delegate?.main(viewController: self, didTapStartAnalysis: ())
    }
    
    @IBAction func showHelp(_ sender: Any) {
        delegate?.main(viewController: self, didTapShowHelp: ())
    }
}
