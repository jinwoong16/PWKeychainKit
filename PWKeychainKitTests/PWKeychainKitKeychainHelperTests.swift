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
    private var serviceName: String = "myService"
    private var token = UserToken(service: "myService", token: "366efe34ca5d41b2ccb406f64f482f35", expireAt: "1697280879")
    private var normalQuery: [String: Any] = [
        kSecAttrService as String: "myService",
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
            try keychainHelper.save(item: token, service: serviceName)
        )
    }
    
    func test_save_whenReplaceItem_shouldNotThrow() throws {
        // Add original one.
        XCTAssertNoThrow(
            try keychainHelper.save(item: token, service: serviceName)
        )
        
        let userToken2 = UserToken(
            service: serviceName,
            token: "123123",
            expireAt: ""
        )
        
        XCTAssertNoThrow(
            try keychainHelper.save(item: userToken2, service: serviceName)
        )
    }
    
    // MARK: KeychainHelper delete tests.
    func test_delete_withValidItem_shouldNotThrow() throws {
        // Add original one.
        XCTAssertNoThrow(
            try keychainHelper.save(item: token, service: serviceName)
        )
        
        XCTAssertNoThrow(
            try keychainHelper.delete(by: serviceName)
        )
    }
    
    func test_delete_withNonExistingItem_sholdThrow() throws {
        XCTAssertThrowsError(
            try keychainHelper.delete(by: serviceName)
        ) { error in
            XCTAssertEqual(
                error as? KeychainError,
                KeychainError.noPassword
            )
        }
    }
    
    // MARK: KeychainHelper read tests.
    func test_read_withExistingItem_shouldReturnPassword() throws {
        // Add original one.
        XCTAssertNoThrow(
            try keychainHelper.save(item: token, service: serviceName)
        )
        
        let result: UserToken = try keychainHelper.read(by: serviceName)
        XCTAssertEqual(result.token, "366efe34ca5d41b2ccb406f64f482f35")
        
    }
    
    func test_read_withNotExistingItem_shouldThrow() throws {
        // Add nothing.
        do {
            let _: UserToken = try keychainHelper.read(by: serviceName)
            XCTFail("This must be failed.")
        } catch {
            XCTAssertEqual(
                error as? KeychainError,
                KeychainError.noPassword
            )
        }
    }
}
