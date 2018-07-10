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
    var logo: UIImage?
    
    init(infoDictionary: [String: Any]) {
        if let primaryColorHex = infoDictionary["Primary color"] as? String,
            let primaryColorValue = Int(primaryColorHex, radix: 16) {
            primaryColor = UIColor(hex: primaryColorValue)
        }
        
        if let secondaryColorHex = infoDictionary["Secondary color"] as? String,
            let secondaryColorValue = Int(secondaryColorHex, radix: 16) {
            secondaryColor = UIColor(hex: secondaryColorValue)
        }
        
        if let logoName = Bundle.main.infoDictionary?["Logo name"] as? String {
            logo = UIImage(named: logoName)
        }
    }
}
