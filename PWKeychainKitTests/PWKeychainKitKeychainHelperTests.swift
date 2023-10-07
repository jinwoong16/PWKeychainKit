//
//  PWKeychainKitKeychainHelperTests.swift
//  PWKeychainKitTests
//
//  Created by jinwoong Kim on 10/7/23.
//

import XCTest
@testable import PWKeychainKit

final class KeychainHelperTests: XCTestCase {
    private var keychainHelper: KeychainHelper!
    private var credentials = Credentials(username: "Aria", password: "creep0101")
    private var normalQuery: [String: Any] = [
        kSecAttrService as String: "credentials.service",
        kSecClass as String: kSecClassGenericPassword
    ]

    override func setUpWithError() throws {
        keychainHelper = DefaultKeychainHelper(
            .genericPassword
        )
    }

    override func tearDownWithError() throws {
        keychainHelper = nil
        
        SecItemDelete(normalQuery as CFDictionary)
    }

    // MARK: KeychainHelper save tests.
    func test_save_withValidItem_shouldNotThrow() throws {
        XCTAssertNoThrow(
            try keychainHelper.save(item: credentials)
        )
    }
    
    func test_save_whenReplaceItem_shouldNotThrow() throws {
        // Add original one.
        XCTAssertNoThrow(
            try keychainHelper.save(item: credentials)
        )
        
        let credentials2 = Credentials(
            username: credentials.username,
            password: "some other password"
        )
        
        XCTAssertNoThrow(
            try keychainHelper.save(item: credentials2)
        )
    }
    
    // MARK: KeychainHelper delete tests.
    func test_delete_withValidItem_shouldNotThrow() throws {
        // Add original one.
        XCTAssertNoThrow(
            try keychainHelper.save(item: credentials)
        )
        
        XCTAssertNoThrow(
            try keychainHelper.delete(item: credentials)
        )
    }
    
    func test_delete_withNotExistItem_sholdThrow() throws {
        // Add original one.
        XCTAssertNoThrow(
            try keychainHelper.save(item: credentials)
        )
        
        let notExistItem = Credentials(
            username: "unknown user",
            password: "unknown password"
        )
        XCTAssertThrowsError(
            try keychainHelper.delete(item: notExistItem)
        ) { error in
            XCTAssertEqual(
                error as? KeychainError,
                KeychainError.noPassword
            )
        }
    }
    
    // MARK: KeychainHelper read tests.
    func test_read_withExistItem_shouldReturnPassword() throws {
        // Add original one.
        XCTAssertNoThrow(
            try keychainHelper.save(item: credentials)
        )
        
        let result = try keychainHelper.read(item: credentials)
        
        XCTAssertEqual(result, credentials.password)
    }
    
    func test_read_withNotExistItem_shouldThrow() throws {
        // Add nothing.
        XCTAssertThrowsError(
            try _ = keychainHelper.read(item: credentials)
        ) { error in
            XCTAssertEqual(
                error as? KeychainError,
                KeychainError.noPassword
            )
        }
    }
}
