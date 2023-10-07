//
//  KeychainResult.swift
//  KeychainHelper
//
//  Created by jinwoong Kim on 2023/09/06.
//

import Foundation

public struct KeychainResult {
    let status: OSStatus
    let object: CFTypeRef?
}
