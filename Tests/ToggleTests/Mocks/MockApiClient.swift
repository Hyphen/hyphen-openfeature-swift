//
//  MockApiClient.swift
//  Toggle
//
//  Created by Jim Newkirk on 4/9/25.
//
import Foundation
@testable import Toggle

final class MockApiClient: ApiClientProtocol {
    public var evaluationResponse: EvaluationResponse?
    public var telemetryResponse: HyphenService.Empty = .init()
    public var error: Error?

    func request<T: Codable, R: Decodable>(
        config: HyphenConfiguration,
        endpoint: Endpoint,
        body: T
    ) async throws -> R? {
        if let error = error {
            throw error
        }

        switch endpoint {
        case .evaluate:
            return evaluationResponse as? R
        case .telemetry:
            return telemetryResponse as? R
        }
    }
}
