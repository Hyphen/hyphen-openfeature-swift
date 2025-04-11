//
//  File.swift
//  Toggle
//
//  Created by Jim Newkirk on 4/9/25.
//

import Foundation
import OpenFeature
@testable import Toggle

extension Evaluation {
    static func mock(
        key: String,
        value: CodableValue,
        typeOverride: String? = nil,
        reason: String? = "mocked",
        errorMessage: String? = nil
    ) -> Evaluation {
        Evaluation(
            key: key,
            value: value,
            type: typeOverride ?? value.valueType,
            reason: reason,
            errorMessage: errorMessage
        )
    }
}

private extension CodableValue {
    var valueType: String {
        switch self {
        case .string: return "string"
        case .int: return "int"
        case .double: return "double"
        case .bool: return "bool"
        case .array: return "array"
        case .dictionary: return "object"
        case .null: return "null"
        }
    }
}




