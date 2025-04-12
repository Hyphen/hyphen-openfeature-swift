import Foundation
@testable import Toggle

extension EvaluationResponse {
    static func mock(
        targetingKey: String = UUID().uuidString,
        id: String = UUID().uuidString,
        evaluations: [Evaluation]
    ) -> EvaluationResponse {
        let toggles = Dictionary(uniqueKeysWithValues: evaluations.map { ($0.key, $0) })
        return EvaluationResponse(id: id, targetingKey: targetingKey, toggles: toggles)
    }
}
