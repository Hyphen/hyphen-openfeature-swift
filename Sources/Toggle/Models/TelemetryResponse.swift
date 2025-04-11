import Foundation

struct TelemetryResponse: Codable, Sendable {
    let context: HyphenEvaluationContext
    let data: TelemetryData
}

struct TelemetryData: Codable, Sendable {
    let toggle: Evaluation
}
