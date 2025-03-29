//
//  UserContext.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/20/25.
//

import Foundation
import OpenFeature

struct UserContext: Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let email: String?
    public let name: String?
    public let customAttributes: [String: CodableValue]

    public var customAttributesAsAny: [String: Any] {
        customAttributes.mapValues { $0.anyValue }
    }

    internal init(
        email: String? = nil,
        name: String? = nil,
        customAttributes: [String: CodableValue] = [:]) {
        self.id = UUID()
        self.email = email
        self.name = name
        self.customAttributes = customAttributes
    }

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case email = "Email"
        case name = "Name"
        case customAttributes = "CustomAttributes"
    }
}

extension UserContext {
    static func make(
        email: String? = nil,
        name: String? = nil,
        customAttributes: [String: Any] = [:]) -> UserContext {
        return UserContext(
            email: email,
            name: name,
            customAttributes: customAttributes.mapValues { CodableValue(any: $0) }
        )
    }
}

extension UserContext {
    static func from(structure: [String: Value]?) -> UserContext? {
        guard let structure else { return nil }

        let email = structure["Email"]?.asString()
        let name = structure["Name"]?.asString()

        var customAttributes: [String: CodableValue] = [:]
        if let customAttrStructure = structure["CustomAttributes"]?.asStructure() {
            for (key, value) in customAttrStructure {
                customAttributes[key] = CodableValue(any: value.toAny())
            }
        }
        
        return UserContext(
            email: email,
            name: name,
            customAttributes: customAttributes
        )
    }
}

extension UserContext {
    static let mock: UserContext = {
        return UserContext.make(email: "matthew@silewski.com",
                                name: "Matthew Osborn",
                                customAttributes: ["role": "admin"])
        
    }()
}



