//
//  UIApplication.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/24/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

extension UIApplication {
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
        if self.canOpenURL(settingsUrl) {
            self.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
}
