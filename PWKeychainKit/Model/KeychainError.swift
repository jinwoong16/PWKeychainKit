//
//  KeychainError.swift
//  KeychainHelper
//
//  Created by jinwoong Kim on 2023/09/06.
//

import Foundation

enum KeychainError: Error, Equatable {
    case noPassword
    case unexpectedPasswordData
    case alreadyExist
    case unhandledError(status: OSStatus)
    case updateValueMissing
    case encodingError
    case decodingError
}
