import Foundation
import Testing
@testable import Toggle

struct EvaluationContextEqualityTests {
    @Test
    func testContextsAreEqual_whenTargetingKeyAndValuesMatch() {
        let contextA = MockEvaluationContext(
            targetingKey: "user-123",
            values: [
                "theme": .string("dark"),
                "age": .integer(30)
            ]
        )

        let contextB = MockEvaluationContext(
            targetingKey: "user-123",
            values: [
                "theme": .string("dark"),
                "age": .integer(30)
            ]
        )

        #expect(true == contextA.isEqual(to: contextB))
    }

    @Test
    func testContextsAreNotEqual_whenTargetingKeysDiffer() {
        let contextA = MockEvaluationContext(
            targetingKey: "user-123",
            values: ["role": .string("admin")]
        )

        let contextB = MockEvaluationContext(
            targetingKey: "user-456",
            values: ["role": .string("admin")]
        )

        #expect(false == contextA.isEqual(to: contextB))
    }

    @Test
    func testContextsAreNotEqual_whenValuesDiffer() {
        let contextA = MockEvaluationContext(
            targetingKey: "user-123",
            values: ["darkMode": .boolean(true)]
        )

        let contextB = MockEvaluationContext(
            targetingKey: "user-123",
            values: ["darkMode": .boolean(false)]
        )

        #expect(false == contextA.isEqual(to: contextB))
    }

    @Test
    func testContextsAreNotEqual_whenKeysDiffer() {
        let contextA = MockEvaluationContext(
            targetingKey: "user-123",
            values: ["plan": .string("free")]
        )

        let contextB = MockEvaluationContext(
            targetingKey: "user-123",
            values: ["tier": .string("free")]
        )

        #expect(false == contextA.isEqual(to: contextB))
    }

    @Test
    func testContextsAreEqual_withEmptyValuesAndSameTargetingKey() {
        let contextA = MockEvaluationContext(
            targetingKey: "anon",
            values: [:]
        )

        let contextB = MockEvaluationContext(
            targetingKey: "anon",
            values: [:]
        )

        #expect(true == contextA.isEqual(to: contextB))
    }
}

