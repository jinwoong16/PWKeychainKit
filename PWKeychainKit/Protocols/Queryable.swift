//
//  Queryable.swift
//  PWKeychainKit
//
//  Created by jinwoong Kim on 10/7/23.
//

import Foundation

public protocol Queryable {
    var query: [String: Any] { get }
}
