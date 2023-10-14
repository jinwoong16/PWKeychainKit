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
    private var token = UserToken(service: "myService", token: "366efe34ca5d41b2ccb406f64f482f35", expireAt: "1697280879")
    private var normalQuery: [String: Any] = [
        kSecAttrService as String: "myService",
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
        var query = normalQuery
        query[kSecValueData as String] = try! encode(data: token)
        let status = keychain.add(item: query)
        
        XCTAssertEqual(status, errSecSuccess)
    }
    
    func test_add_withDuplicatedOne_shouldReturnError() throws {
        // Add first.
        var query = normalQuery
        query[kSecValueData as String] = try! encode(data: token)
        let statusOne = keychain.add(item: query)
        XCTAssertEqual(statusOne, errSecSuccess)
        
        // Add second.
        let statusTwo = keychain.add(item: query)
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
        var query = normalQuery
        query[kSecValueData as String] = try! encode(data: token)
        let status = keychain.add(item: query)
        XCTAssertEqual(status, errSecSuccess)
        
        var fetchQuery = normalQuery
        fetchQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        fetchQuery[kSecReturnData as String] = kCFBooleanTrue
        fetchQuery[kSecReturnAttributes as String] = kCFBooleanTrue
        let result = keychain.fetch(with: fetchQuery)
        XCTAssertEqual(result.status, errSecSuccess)
        
        let item = try XCTUnwrap(result.object as? [String: Any])
        let username = try XCTUnwrap(item[kSecAttrAccount as String] as? String)
        let encodedData = try XCTUnwrap(item[kSecValueData as String] as? Data)
        let userToken: UserToken = try XCTUnwrap(try? decode(data: encodedData))
        
        XCTAssertEqual(userToken.token, "366efe34ca5d41b2ccb406f64f482f35")
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
        var query = normalQuery
        query[kSecValueData as String] = try! encode(data: token)
        let statusOne = keychain.add(item: query)
        XCTAssertEqual(statusOne, errSecSuccess)
        
        // Delete the item.
        let statusTwo = keychain.delete(item: normalQuery)
        XCTAssertEqual(statusTwo, errSecSuccess)
    }
    
    func test_delete_withNotExistItem_shouldReturnError() throws {
        let status = keychain.delete(item: normalQuery)
        XCTAssertEqual(status, errSecItemNotFound)
    }
    
    // MARK: - Keychain update tests.
    func test_update_withNewCredential_shouldReplaceOriginOne() throws {
        var fetchQuery = normalQuery
        fetchQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        fetchQuery[kSecReturnData as String] = kCFBooleanTrue
        fetchQuery[kSecReturnAttributes as String] = kCFBooleanTrue
        
        let updatedToken = try! encode(data: UserToken(service: "myService", token: "234234", expireAt: ""))
        
        let toUpdateQuery: [String: Any] = [
            kSecValueData as String: updatedToken
        ]
        
        // Add an item.
        var query = normalQuery
        query[kSecValueData as String] = try! encode(data: token)
        let statusOne = keychain.add(item: query)
        XCTAssertEqual(statusOne, errSecSuccess)
        
        // Update the item.
        let statusTwo = keychain.update(item: normalQuery, with: toUpdateQuery)
        XCTAssertEqual(statusTwo, errSecSuccess)
        
        var item: CFTypeRef?
        let statusThree = SecItemCopyMatching(
            fetchQuery as CFDictionary,
            &item
        )
        XCTAssertEqual(statusThree, errSecSuccess)
        
        let dictionary = try XCTUnwrap(item as? [String: Any])
        let username = try XCTUnwrap(dictionary[kSecAttrAccount as String] as? String)
        let encodedData = try XCTUnwrap(dictionary[kSecValueData as String] as? Data)
        let userToken: UserToken = try XCTUnwrap(try? decode(data: encodedData))
        XCTAssertEqual(userToken.token, "234234")
    }
}

extension KeychainTests {
    private func decode<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    private func encode<T: Encodable>(data: T) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(data)
    }
}
