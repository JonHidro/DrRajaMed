//
//  AuthHelper.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/29/25.
//

//
//  AuthHelper.swift
//  YourProjectName
//
//  Created by Your Name on [Date].
//

import Foundation
import CryptoKit

/// Generates a random nonce string of the given length.
/// - Parameter length: The desired length of the nonce. Default is 32.
/// - Returns: A random alphanumeric string.
func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        // Generate 16 random bytes
        let randoms: [UInt8] = (0..<16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }

        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    return result
}

/// Returns the SHA256 hash of the input string.
/// - Parameter input: The string to hash.
/// - Returns: A hexadecimal representation of the SHA256 hash.
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
}
