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
    /// Reads an item using its service name.
    ///
    /// - Parameter service: the service name of item.
    /// - Throws: `KeychainError`
    /// - Returns: a decoded data if successful.
    func read<T: Decodable>(by service: String) throws -> T
    
    /// Saves an item using its service name or
    /// updates it if it already exists.
    ///
    /// - Parameters
    ///     - item: an item to be added.
    ///     - service: the service name of item.
    /// - Throws: `KeychainError`
    func save<T: Codable>(item: T, service: String) throws
    
    /// Deletes an item using its service name.
    ///
    /// - Parameter service: the service name of item.
    /// - Throws: `KeychainError`
    func delete(by service: String) throws
}

public final class DefaultKeychainHelper {
    private let keychain: Keychain
    private let normalQuery: Queryable
    
    public init(_ keychainClass: KeychainClass) {
        switch keychainClass {
            case .genericPassword:
                self.keychain = DefaultKeychain()
                self.normalQuery = Query(
                    query: [
                        kSecClass as String: kSecClassGenericPassword
                    ]
                )
        }
    }
}

extension DefaultKeychainHelper: KeychainHelper {
    public func read<T>(by service: String) throws -> T where T : Decodable {
        var query = normalQuery.query
        query[kSecAttrService as String] = service
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
              let data = object[kSecValueData as String] as? Data,
              let decodedData: T = try? decode(data: data) else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return decodedData
    }
    
    public func save<T>(item: T, service: String) throws where T : Codable {
        do {
            let _: T = try read(by: service)
            let updatedValue = try encode(data: item)
            
            var original = normalQuery.query
            original[kSecAttrService as String] = service
            
            let query = [
                kSecValueData as String: updatedValue
            ]
            
            let status = keychain.update(item: original, with: query)
            
            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
        } catch KeychainError.noPassword {
            guard let encodedData = try? encode(data: item) else {
                throw KeychainError.encodingError
            }
            
            var query = normalQuery.query
            query[kSecAttrService as String] = service
            query[kSecValueData as String] = encodedData
            
            let status = keychain.add(item: query)
            
            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
        }
    }
    
    public func delete(by service: String) throws {
        var query = normalQuery.query
        query[kSecAttrService as String] = service
        
        let status = keychain.delete(item: query)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    private func decode<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    private func encode<T: Encodable>(data: T) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(data)
    }
}
