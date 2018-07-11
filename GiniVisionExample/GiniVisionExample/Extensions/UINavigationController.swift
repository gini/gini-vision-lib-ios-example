//
//  UINavigationController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/29/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

extension UINavigationController {
    func apply(_ theme: Theme) {
        self.navigationBar.barTintColor = theme.primaryColor
        self.navigationBar.tintColor = theme.secondaryColor
        var attributes = self.navigationBar.titleTextAttributes ?? [NSAttributedStringKey: Any]()
        attributes[NSAttributedStringKey.foregroundColor] = theme.secondaryColor
        self.navigationBar.titleTextAttributes = attributes
    }
}
