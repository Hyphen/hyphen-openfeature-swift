//
//  HyphenEvaluationContext.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/20/25.
//

import Foundation
import UIKit
import OpenFeature

struct HyphenEvaluationContext: Identifiable, Codable, Equatable, Hashable, Sendable {
    // MARK: - Public Properties
    public let targetingKey: String
    public let application: String
    public let environment: String
    public var customAttributes: [String: CodableValue]
    public let user: UserContext?
    
    public var id: String {
        return targetingKey
    }
    
    public var customAttributesAsAny: [String: Any] {
        customAttributes.mapValues { $0.anyValue }
    }
    
    internal init(
        targetingKey: String,
        application: String,
        environment: String,
        customAttributes: [String: CodableValue] = [:],
        user: UserContext? = nil
    ) {
        self.targetingKey = targetingKey
        self.application = application
        self.environment = environment
        
        self.customAttributes = customAttributes
        self.customAttributes["bundle-identifier"] = CodableValue(any: Bundle.main.bundleIdentifier ?? String.Empty)
        self.customAttributes["buildConfiguration"] = CodableValue(any: BuildConfig.buildType)
        
        self.customAttributes["appVersion"] = CodableValue(any: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? String.Empty)
        self.customAttributes["buildVersion"] = CodableValue(any: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? String.Empty)
        self.user = user
    }
}

extension HyphenEvaluationContext {
    static func from(context: EvaluationContext?, application: String, environment: String) -> HyphenEvaluationContext? {
        guard let context else { return nil }

        let map = context.asMap()

        guard let targetingKey = context.getTargetingKey().nilIfEmpty else {
            return nil
        }

        let customAttributes: [String: CodableValue] = map["CustomAttributes"]?
            .asStructure()?
            .mapValues { CodableValue(any: $0.toAny()) } ?? [:]

        let user = UserContext.from(structure: map["User"]?.asStructure())

        return HyphenEvaluationContext(
            targetingKey: targetingKey,
            application: application,
            environment: environment,
            customAttributes: customAttributes,
            user: user
        )
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
    
    static let Empty = ""
}

#if DEBUG
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
#endif


