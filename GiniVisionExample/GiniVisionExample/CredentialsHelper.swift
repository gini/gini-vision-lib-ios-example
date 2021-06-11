//
//  CredentialsHelper.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 4/8/19.
//  Copyright © 2019 Gini. All rights reserved.
//

import Foundation

struct CredentialsHelper {
    static func fetchCredentials() -> (id: String?, password: String?) {
        let clientID = "client_id"
        let clientPassword = "client_password"
        
        if let path = Bundle.main.path(forResource: "Credentials", ofType: "plist"),
            let keys = NSDictionary(contentsOfFile: path),
            let client_id = keys[clientID] as? String,
            let client_password = keys[clientPassword] as? String,
            !client_id.isEmpty, !client_password.isEmpty {
            
            return (client_id, client_password)
        }
        return (ProcessInfo.processInfo.environment["client_id"],
                ProcessInfo.processInfo.environment["client_password"])
    }
}
