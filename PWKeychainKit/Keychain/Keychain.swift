//
//  Keychain.swift
//  KeychainHelper
//
//  Created by jinwoong Kim on 2023/09/06.
//

import Foundation

protocol Keychain {
    /// Adds an item into the keychain.
    ///
    /// - Parameter query: a dictionary data that can be added to the keychain.
    /// - Returns: an os status code representing the result.
    func add(item query: [String: Any]) -> OSStatus
    
    /// Fetchs an item from the keychain.
    ///
    /// - Parameter query: a dictionary data that you want to find in the keychain.
    /// - Returns: a `KeychainResult` type data that includes the osstatus and item data if it exists.
    func fetch(with query: [String: Any]) -> KeychainResult
    
    /// Deletes all items in the keychain.
    ///
    /// - Parameter query: a search query to delete. Note, this operation will delete all items that match the query.
    /// - Returns: an os status code representing the result.
    func delete(item query: [String: Any]) -> OSStatus
    
    /// Updates an item with a new one.
    ///
    /// - Parameters:
    ///     - query: an item query that will be replaced.
    ///     - attributes: attributes that want to change.
    /// - Returns: an os status code representing the result.
    func update(item query: [String: Any], with attributes: [String: Any]) -> OSStatus
}

final class DefaultKeychain: Keychain {
    func add(item query: [String : Any]) -> OSStatus {
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    func fetch(with query: [String : Any]) -> KeychainResult {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        return KeychainResult(status: status, object: item)
    }
    
    func delete(item query: [String : Any]) -> OSStatus {
        return SecItemDelete(query as CFDictionary)
    }
    
    func update(item query: [String : Any], with attributes: [String : Any]) -> OSStatus {
        return SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
    }
}
