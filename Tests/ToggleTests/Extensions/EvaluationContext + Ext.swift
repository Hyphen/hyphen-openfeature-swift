import Foundation
import OpenFeature

extension EvaluationContext {
    func isEqual(to other: EvaluationContext) -> Bool {
        return self.getTargetingKey() == other.getTargetingKey()
            && self.asMap() == other.asMap()
    }
}
