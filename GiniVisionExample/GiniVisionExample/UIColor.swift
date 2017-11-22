//
//  UIColor.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var giniBlue: UIColor {
        return UIColor(hex: 0x009EDC)
    }
    
    static var giniGreen: UIColor {
        return UIColor(hex: 0x1AE2AE)
    }
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}

