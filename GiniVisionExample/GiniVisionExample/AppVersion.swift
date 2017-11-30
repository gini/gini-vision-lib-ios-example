//
//  AppVersion.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/22/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import GiniVision
import Gini_iOS_SDK

final class AppVersion {
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    static let gvlVersion = Bundle(for: GiniVision.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    static let apisdkVersion = Bundle(for: GiniSDK.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

}
