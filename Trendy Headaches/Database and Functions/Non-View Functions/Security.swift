//
//  Security.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/20/25.
//

import CryptoKit
import Foundation

func hashString(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
}
