//
//  UINavigationController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/29/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

extension UINavigationController {
    func applyGiniStyle() {
        self.navigationBar.barTintColor = .giniBlue
        self.navigationBar.tintColor = .white
        var attributes = self.navigationBar.titleTextAttributes ?? [NSAttributedStringKey: Anyç]()
        attributes[NSAttributedStringKey.foregroundColor] = UIColor.white
        self.navigationBar.titleTextAttributes = attributes
    }
}
