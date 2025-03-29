import Foundation
import OpenFeature
@testable import Toggle

class MockEvaluationContext: EvaluationContext {
    private var targetingKeyValue: String
    private var values: [String: Value]

    init(targetingKey: String, values: [String: Value]) {
        self.targetingKeyValue = targetingKey
        self.values = values
    }

    func getTargetingKey() -> String {
        targetingKeyValue
    }

    func setTargetingKey(targetingKey: String) {
        self.targetingKeyValue = targetingKey
    }

    func keySet() -> Set<String> {
        Set(values.keys)
    }

    func getValue(key: String) -> Value? {
        values[key]
    }

    func asMap() -> [String: Value] {
        values
    }

    func asObjectMap() -> [String: AnyHashable?] {
        values.mapValues { $0.toAny() as? AnyHashable }
    }
}

