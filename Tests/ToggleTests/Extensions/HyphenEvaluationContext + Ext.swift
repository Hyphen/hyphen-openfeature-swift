import Foundation
@testable import Toggle

extension HyphenEvaluationContext {
    static var mock: HyphenEvaluationContext {
        HyphenEvaluationContext(
            targetingKey: "mock-user-id",
            application: "application",
            environment: "environment",
            customAttributes: [
                "role": .string("tester"),
                "featureFlagEnabled": .bool(true),
                "buildNumber": .int(42)
            ],
            user: .mock
        )
    }
}
