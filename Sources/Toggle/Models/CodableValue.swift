import Foundation

public enum CodableValue: Codable, Equatable, Hashable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([CodableValue])
    case dictionary([String: CodableValue])
    case null

    public init(any value: Any) {
        switch value {
        case let v as String:
            self = .string(v)
        case let v as NSNumber:
            let cfTypeID = CFGetTypeID(v)
            if cfTypeID == CFBooleanGetTypeID() {
                self = .bool(v.boolValue)
            } else if v.doubleValue == floor(v.doubleValue) {
                self = .int(v.intValue)
            } else {
                self = .double(v.doubleValue)
            }
        case let v as Int:
            self = .int(v)
        case let v as Double:
            self = .double(v)
        case let v as Bool:
            self = .bool(v)
        case let v as [Any]:
            self = .array(v.map { CodableValue(any: $0) })
        case let v as [String: Any]:
            self = .dictionary(v.mapValues { CodableValue(any: $0) })
        default:
            self = .null
        }
    }

    // MARK: - Type-safe accessors
    public var string: String? {
        if case .string(let v) = self { return v }
        return nil
    }

    public var int: Int? {
        if case .int(let v) = self { return v }
        return nil
    }

    public var double: Double? {
        if case .double(let v) = self { return v }
        return nil
    }

    public var bool: Bool? {
        if case .bool(let v) = self { return v }
        return nil
    }

    public var array: [CodableValue]? {
        if case .array(let v) = self { return v }
        return nil
    }

    public var dictionary: [String: CodableValue]? {
        if case .dictionary(let v) = self { return v }
        return nil
    }

    public var isNull: Bool {
        if case .null = self { return true }
        return false
    }

    public var anyValue: Any {
        switch self {
        case .string(let v): return v
        case .int(let v): return v
        case .double(let v): return v
        case .bool(let v): return v
        case .array(let v): return v.map { $0.anyValue }
        case .dictionary(let v): return v.mapValues { $0.anyValue }
        case .null: return NSNull()
        }
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([CodableValue].self) {
            self = .array(array)
        } else if let dict = try? container.decode([String: CodableValue].self) {
            self = .dictionary(dict)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to decode CodableValue"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .dictionary(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }

    // MARK: - Subscript for dictionary access
    public subscript(key: String) -> CodableValue? {
        if case .dictionary(let dict) = self {
            return dict[key]
        }
        return nil
    }
}

extension CodableValue {
    func unwrapJSONStringIfNeeded() -> CodableValue {
        guard case let .string(jsonString) = self,
              let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            return self
        }

        if let dict = jsonObject as? [String: Any] {
            return .dictionary(dict.mapValues { CodableValue(any: $0) })
        } else if let array = jsonObject as? [Any] {
            return .array(array.map { CodableValue(any: $0) })
        } else {
            return self
        }
    }
}

