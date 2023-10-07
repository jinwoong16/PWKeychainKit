//
//  Credentials.swift
//  KeychainHelper
//
//  Created by jinwoong Kim on 2023/09/06.
//

import Foundation

struct Credentials {
    var username: String
    var password: String
}

extension Credentials: Queryable {
    var query: [String : Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: password.data(using: .utf8)!,
            kSecAttrAccount as String: username,
            kSecAttrService as String: "credentials.service"
        ]
    }
}
