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
        var attributes = self.navigationBar.titleTextAttributes ?? [NSAttributedString.Key: Any]()
        attributes[NSAttributedString.Key.foregroundColor] = theme.secondaryColor
        self.navigationBar.titleTextAttributes = attributes
        if #available(iOS 11.0, *) {
            self.navigationBar.largeTitleTextAttributes = attributes
        }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = theme.primaryColor
            var attributes = self.navigationBar.titleTextAttributes ?? [NSAttributedString.Key: Any]()
            attributes[NSAttributedString.Key.foregroundColor] = theme.secondaryColor
            appearance.titleTextAttributes = attributes
            appearance.largeTitleTextAttributes = attributes
                   
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
