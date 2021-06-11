//
//  MainViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/20/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit
import GiniVision
protocol MainViewControllerDelegate: AnyObject {
    func main(viewController: MainViewController, didTapStartAnalysis: ())
    func main(viewController: MainViewController, didTapShowHelp: ())
}

final class MainViewController: UIViewController {

    let theme: Theme
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var analyzeButton: UIButton! {
        didSet {
            analyzeButton.layer.shadowColor = UIColor.black.cgColor
            analyzeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            analyzeButton.layer.shadowRadius = 2
            analyzeButton.layer.shadowOpacity = 0.2
            analyzeButton.layer.masksToBounds = false
            analyzeButton.setTitle(NSLocalizedString("start.analysis.button",
                                                     comment: "start anysis button on main screen"), for: .normal)
        }
    }
    @IBOutlet weak var appVersion: UILabel! {
        didSet {
            appVersion.text = "\(AppVersion.appVersion) (\(AppVersion.buildNumber))"
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
    
    init(theme: Theme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.primaryColor
        logoImage.image = theme.logo
        helpButton.tintColor = theme.primaryColor
        analyzeButton.backgroundColor = theme.buttonsColor
        analyzeButton.titleLabel?.font = GiniConfiguration().customFont.with(weight: .regular, size: 14, style: .caption1)
        analyzeButton.layer.cornerRadius = 7
        appVersion.textColor = theme.primaryColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
