//
//  EvaluationResponse.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/21/25.
//
import Foundation

struct EvaluationResponse: Codable, Sendable {
    let id: String
    let targetingKey: String
    let toggles: [String: Evaluation]
}

struct Evaluation: Codable, Sendable {
    let key: String
    let value: CodableValue
    let type: String
    let reason: String?
    let errorMessage: String? 
}
