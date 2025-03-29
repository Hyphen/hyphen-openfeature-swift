import Foundation
import OpenFeature

extension Value {
    func toAny() -> Any {
        switch self {
        case .boolean(let b): return b
        case .string(let s): return s
        case .integer(let i): return Int(i)
        case .double(let d): return d
        case .date(let d): return d
        case .list(let values): return values.map { $0.toAny() }
        case .structure(let dict): return dict.mapValues { $0.toAny() }
        case .null: return NSNull()
        }
    }
}
