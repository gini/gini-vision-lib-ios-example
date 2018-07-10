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

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var analyzeButton: UIButton! {
        didSet {
            analyzeButton.layer.shadowColor = UIColor.black.cgColor
            analyzeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            analyzeButton.layer.shadowRadius = 2
            analyzeButton.layer.shadowOpacity = 0.2
            analyzeButton.layer.masksToBounds = false
        }
    }
    @IBOutlet weak var appVersion: UILabel! {
        didSet {
            appVersion.text = AppVersion.appVersion
        }
    }
    
    weak var delegate: MainViewControllerDelegate?

    @IBAction func startAnalysis(_ sender: Any) {
        delegate?.main(viewController: self, didTapStartAnalysis: ())
    }
    
    @IBAction func showHelp(_ sender: Any) {
        delegate?.main(viewController: self, didTapShowHelp: ())
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let logoName = Bundle.main.infoDictionary?["Logo name"] as? String {
            logoImage.image = UIImage(named: logoName)
        }
        
        if let primaryColorHex = Bundle.main.infoDictionary?["Primary color"] as? String {
            view.backgroundColor = UIColor(hex: Int(primaryColorHex) ?? 0xFFFFFF)
        }
    }
}
