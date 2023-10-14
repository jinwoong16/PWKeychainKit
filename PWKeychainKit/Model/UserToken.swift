//
//  UserToken.swift
//  PWKeychainKit
//
//  Created by jinwoong Kim on 10/13/23.
//

import Foundation

public struct UserToken: Codable {
    public var service: String
    public var token: String
    public var expireAt: String
    
    public init(service: String, token: String, expireAt: String) {
        self.service = service
        self.token = token
        self.expireAt = expireAt
    }
}
