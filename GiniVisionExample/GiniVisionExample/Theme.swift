//
//  Theme.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 7/10/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import UIKit

struct Theme {
    var primaryColor: UIColor = .white
    var secondaryColor: UIColor = .black
    var buttonsColor: UIColor = .green
    var logo: UIImage?
    var showPhotoPaymentLabel: Bool = false
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    init(infoDictionary: [String: Any]) {
        if let primaryColorHex = infoDictionary["Primary color"] as? String,
            let primaryColorValue = Int(primaryColorHex, radix: 16) {
            primaryColor = UIColor(hex: primaryColorValue)
        }
        
        if let secondaryColorHex = infoDictionary["Secondary color"] as? String,
            let secondaryColorValue = Int(secondaryColorHex, radix: 16) {
            secondaryColor = UIColor(hex: secondaryColorValue)
        }
        
        if let logoName = infoDictionary["Logo name"] as? String {
            logo = UIImage(named: logoName)
        }
        
        if let photoPaymentLabel = infoDictionary["Show photo payment label"] as? String {
            showPhotoPaymentLabel = photoPaymentLabel == "YES"
        }
        
        if let style = infoDictionary["UIStatusBarStyle"] as? String {
            statusBarStyle = style == "UIStatusBarStyleDefault" ? .default : .lightContent
        }
        
        if let buttonsColorHex = infoDictionary["Buttons color"] as? String,
            let buttonsColorValue = Int(buttonsColorHex, radix: 16) {
            buttonsColor = UIColor(hex: buttonsColorValue)
        }
    }
}
