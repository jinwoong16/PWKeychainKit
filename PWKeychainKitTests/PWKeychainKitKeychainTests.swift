//
//  PWKeychainKitKeychainTests.swift
//  PWKeychainKitTests
//
//  Created by jinwoong Kim on 10/7/23.
//

import XCTest
@testable import PWKeychainKit

final class KeychainTests: XCTestCase {
    private var keychain: Keychain!
    private var credentials = Credentials(username: "Aria", password: "creep0101")
    private var normalQuery: [String: Any] = [
        kSecAttrService as String: "credentials.service",
        kSecClass as String: kSecClassGenericPassword
    ]
    
    override func setUpWithError() throws {
        keychain = DefaultKeychain()
    }
    
    override func tearDownWithError() throws {
        keychain = nil
        
        SecItemDelete(normalQuery as CFDictionary)
    }

    // MARK: - Keychain add tests.
    func test_add_withValidItem_shouldReturnSuccess() throws {
        let status = keychain.add(item: credentials.query)
        XCTAssertEqual(status, errSecSuccess)
    }
    
    func test_add_withDuplicatedOne_shouldReturnError() throws {
        // Add first.
        let statusOne = keychain.add(item: credentials.query)
        XCTAssertEqual(statusOne, errSecSuccess)
        
        // Add second.
        let statusTwo = keychain.add(item: credentials.query)
        XCTAssertEqual(statusTwo, errSecDuplicateItem)
    }
    
    // MARK: - Keychain fetch tests.
    /// To fetch an item,
    /// the query has additional properies.
    ///
    /// - `kSecReturnData`: a key whose value is a boolean indicating whether or not to return item data.
    /// - `kSecMatchLimit`: a key whose value indicates the match limit.
    /// - `kSecReturnAttributes`: a key whose value is a Boolean indicating whether or not to return item attributes.
    func test_fetch_withValidQuery_shouldReturnSuccess() throws {
        // Add an item.
        let status = keychain.add(item: credentials.query)
        XCTAssertEqual(status, errSecSuccess)
        
        var query = normalQuery
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        let result = keychain.fetch(with: query)
        XCTAssertEqual(result.status, errSecSuccess)
        
        let item = try XCTUnwrap(result.object as? [String: Any])
        let username = try XCTUnwrap(item[kSecAttrAccount as String] as? String)
        let passwordData = try XCTUnwrap(item[kSecValueData as String] as? Data)
        let password = try XCTUnwrap(String(data: passwordData, encoding: .utf8))
        XCTAssertEqual(username, credentials.username)
        XCTAssertEqual(password, credentials.password)
    }
    
    func test_fetch_withNotExistItem_shouldReturnError() throws {
        var query = normalQuery
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        let result = keychain.fetch(with: query)
        XCTAssertEqual(result.status, errSecItemNotFound)
        XCTAssertNil(result.object)
    }
    
    // MARK: - Keychain delete tests.
    func test_delete_withExistItem_shouldReturnSuccess() throws {
        // Add an item.
        let statusOne = keychain.add(item: credentials.query)
        XCTAssertEqual(statusOne, errSecSuccess)
        
        let statusTwo = keychain.delete(item: normalQuery)
        XCTAssertEqual(statusTwo, errSecSuccess)
    }
    
    func test_delete_withNotExistItem_shouldReturnError() throws {
        // Add an item.
        let status = keychain.delete(item: normalQuery)
        XCTAssertEqual(status, errSecItemNotFound)
    }
    
    // MARK: - Keychain update tests.
    func test_update_withNewCredential_shouldReplaceOriginOne() throws {
        var query = normalQuery
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        let toUpdateQuery: [String: Any] = [
            kSecValueData as String: "NotCreep0101".data(using: .utf8)!
        ]
        
        // Add an item.
        let statusOne = keychain.add(item: credentials.query)
        XCTAssertEqual(statusOne, errSecSuccess)
        
        // Update the item.
        let statusTwo = keychain.update(item: normalQuery, with: toUpdateQuery)
        XCTAssertEqual(statusTwo, errSecSuccess)
        
        var item: CFTypeRef?
        let statusThree = SecItemCopyMatching(
            query as CFDictionary,
            &item
        )
        XCTAssertEqual(statusThree, errSecSuccess)
        
        let dictionary = try XCTUnwrap(item as? [String: Any])
        let username = try XCTUnwrap(dictionary[kSecAttrAccount as String] as? String)
        let passwordData = try XCTUnwrap(dictionary[kSecValueData as String] as? Data)
        let password = try XCTUnwrap(String(data: passwordData, encoding: .utf8))
        XCTAssertEqual(username, "Aria")
        XCTAssertEqual(password, "NotCreep0101")
    }
}
