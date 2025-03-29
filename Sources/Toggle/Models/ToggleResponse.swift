//
//  ToggleResponse.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/25/25.
//
import Foundation

struct TelemetryPayload: Codable, Sendable {
    let context: HyphenEvaluationContext
    let data: TelemetryData
}

struct TelemetryData: Codable, Sendable {
    let toggle: Evaluation
}
