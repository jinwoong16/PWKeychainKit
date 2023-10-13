//
//  Credentials.swift
//  KeychainHelper
//
//  Created by jinwoong Kim on 2023/09/06.
//

import Foundation

public struct Credentials {
    var username: String
    var password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

extension Credentials: Queryable {
    public var query: [String : Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: password.data(using: .utf8)!,
            kSecAttrAccount as String: username,
            kSecAttrService as String: "credentials.service"
        ]
    }
}
