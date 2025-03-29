//
//  PublicKey.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/21/25.
//

import Foundation

public struct PublicKey {
    public let key: String

    public init(_ key: String) {
        self.key = key
    }

    public var orgId: String? {
        let keyWithoutPrefix = key.replacingOccurrences(of: "public_", with: "")

        guard let decodedData = Data(base64Encoded: keyWithoutPrefix),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }

        let parts = decodedString.split(separator: ":")
        guard parts.count >= 2 else {
            return nil
        }

        let orgId = String(parts[0])
        let pattern = "^[a-zA-Z0-9_-]+$"
        let range = NSRange(location: 0, length: orgId.utf16.count)
        let regex = try? NSRegularExpression(pattern: pattern)

        return regex?.firstMatch(in: orgId, options: [], range: range) != nil ? orgId : nil
    }
}

