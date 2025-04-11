//
//  EvaluationCache.swift
//  Toggle
//
//  Created by Jim Newkirk on 4/10/25.
//
import Foundation

internal final class EvaluationCache {
    private let queue = DispatchQueue(label: "ai.hyphen.EvaluationCacheQueue", attributes: .concurrent)
    private var cached: CachedEvaluationResponse?

    internal init(cached: CachedEvaluationResponse? = nil) {
        self.cached = cached
    }

    func isExpired() -> Bool {
        return queue.sync {
            guard let cached else { return true }
            return cached.isExpired
        }
    }

    func set(_ response: EvaluationResponse, ttl: TimeInterval) {
        queue.async(flags: .barrier) {
            self.cached = CachedEvaluationResponse.withTTL(response, ttl: ttl * 60)
        }
    }

    var evaluationResponse: EvaluationResponse? {
        return queue.sync {
            return cached?.response
        }
    }
}

internal struct CachedEvaluationResponse {
    let response: EvaluationResponse
    let expiresAt: Date

    var isExpired: Bool {
        Date.now >= expiresAt
    }

    static func withTTL(_ response: EvaluationResponse, ttl: TimeInterval = 5 * 60) -> CachedEvaluationResponse {
        CachedEvaluationResponse(
            response: response,
            expiresAt: Date.now.addingTimeInterval(ttl)
        )
    }
}
