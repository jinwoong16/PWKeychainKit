//
//  UserToken.swift
//  PWKeychainKit
//
//  Created by jinwoong Kim on 10/13/23.
//

import Foundation

public struct UserToken {
    var service: String
    var token: String
    
    public init(service: String, token: String) {
        self.service = service
        self.token = token
    }
}

extension UserToken: Queryable {
    public var query: [String : Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: token,
            kSecAttrService as String: service
        ]
    }
}
