//
//  MainViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate: class {
    func main(viewController: UIViewController, didTapStartAnalysis:())
    func main(viewController: UIViewController, didTapShowHelp:())

}

final class MainViewController: UIViewController {
    
    weak var delegate: MainViewControllerDelegate?
    
    @IBAction func startAnalysis(_ sender: Any) {
        delegate?.main(viewController: self, didTapStartAnalysis: ())
    }
    
    @IBAction func showHelp(_ sender: Any) {
        delegate?.main(viewController: self, didTapShowHelp: ())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
