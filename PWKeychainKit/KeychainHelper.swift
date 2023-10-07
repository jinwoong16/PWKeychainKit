//
//  KeychainHelper.swift
//  KeychainHelper
//
//  Created by jinwoong Kim on 2023/09/06.
//

import Foundation

public enum KeychainClass {
    case genericPassword
}

public protocol KeychainHelper {
    /// Saves an item using 'Queryable' type data or
    /// updates it if it already exists.
    ///
    /// - Parameter item: an item to be added.
    /// - Throws: `KeychainError`
    func save(item: Queryable) throws
    
    /// Deletes an item using `Queryable` type data.
    ///
    /// - Parameter item: an item to be eliminated.
    /// - Throws: `KeychainError`
    func delete(item: Queryable) throws
    
    /// Reads an item using `Queryable` type data.
    ///
    /// - Parameter item: an item to be searched.
    /// - Throws: `KeychainError`
    /// - Returns: if successful, the password string will be returned.
    func read(item: Queryable) throws -> String
}

public final class DefaultKeychainHelper: KeychainHelper {
    private let keychain: Keychain
    
    public init(_ keychainClass: KeychainClass) {
        switch keychainClass {
            case .genericPassword:
                self.keychain = DefaultKeychain()
        }
    }
    
    internal init(_ keychain: Keychain) {
        self.keychain = keychain
    }
    
    public func save(item: Queryable) throws {
        do {
            try _ = read(item: item)
            
            // TODO: do update this item.
            guard let toUpdateValue = item.query[kSecValueData as String] else {
                throw KeychainError.updateValueMissing
            }
            
            let attributes: [String: Any] = [
                kSecValueData as String: toUpdateValue
            ]
            let status = keychain.update(item: item.query, with: attributes)

            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
        } catch KeychainError.noPassword {
            // TODO: do add new keychain item.
            let status = keychain.add(item: item.query)
            
            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
        }
    }
    
    public func delete(item: Queryable) throws {
        let status = keychain.delete(item: item.query)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public func read(item: Queryable) throws -> String {
        var query = item.query
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        let result = keychain.fetch(with: query)
        
        guard result.status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        guard result.status == errSecSuccess else {
            throw KeychainError.unhandledError(status: result.status)
        }
        
        guard let object = result.object,
              let passwordData = object[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
}
