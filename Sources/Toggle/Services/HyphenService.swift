import Foundation
import Network
import OpenFeature

struct HyphenService {
    internal init(using configuration: HyphenConfiguration, apiClient: ApiClientProtocol = ApiClient(), eventHandler: EventHandler) {
        self.configuration = configuration
        self.apiClient = apiClient
        self.eventHandler = eventHandler
    }

    private let configuration: HyphenConfiguration
    private let apiClient: ApiClientProtocol
    private let eventHandler: EventHandler
    private var evaluationCache = EvaluationCache()

    public mutating func evaluate(with evaluationContext: EvaluationContext?)
        async throws
    {
        guard evaluationContext?.getTargetingKey() != nil else {
            throw OpenFeatureError.targetingKeyMissingError
        }

        do {
            let context = HyphenEvaluationContext.from(
                context: evaluationContext,
                application: configuration.application,
                environment: configuration.environment)

            let evaluationResponse: EvaluationResponse? = try await apiClient
                .request(
                    config: configuration,
                    endpoint: .evaluate,
                    body: context
                )

            if let evaluationResponse {
                let cachedEvaluationResponse = CachedEvaluationResponse.withTTL(evaluationResponse, ttl: configuration.networkOptions.cacheExpiration)
                self.evaluationCache = EvaluationCache(cached: cachedEvaluationResponse)
            }
        } catch {
            LoggerManager.shared.error("Evaluation failed: \(error.localizedDescription)")
        }
    }

    struct Empty: Codable {}

    public func telemetry<HookValue>(
        evaluationContext: EvaluationContext,
        details: FlagEvaluationDetails<HookValue>
    ) async {
        guard configuration.enableToggleUsage else { return }

        guard let hyphenContext = HyphenEvaluationContext.from(
            context: evaluationContext,
            application: configuration.application,
            environment: configuration.environment)
        else {
            LoggerManager.shared.error("Failed to create HyphenEvaluationContext - telemetry failed")
            return
        }

        let type: String = details.flagMetadata["type"]?.asString() ?? String(describing: type(of: details.value))

        let evaluation = Evaluation(
            key: details.flagKey,
            value: CodableValue(any: details.value),
            type: type,
            reason: details.reason,
            errorMessage: details.errorMessage
        )

        do {
            let data = TelemetryData(toggle: evaluation)
            let telemetry = TelemetryResponse(context: hyphenContext, data: data)

            _ = try await apiClient.request(
                    config: configuration,
                    endpoint: .telemetry,
                    body: telemetry
                ) as Empty?
        } catch {
            LoggerManager.shared.error("Telemetry update failed: \(error.localizedDescription)")
        }
    }

    func getBooleanEvaluation(
        key: String,
        defaultValue: Bool,
        context: EvaluationContext?
    ) throws -> OpenFeature.ProviderEvaluation<Bool> {
        try getEvaluation(
            key: key, defaultValue: defaultValue, context: context,
            extract: { $0.bool })
    }

    func getStringEvaluation(
        key: String,
        defaultValue: String,
        context: EvaluationContext?
    ) throws -> OpenFeature.ProviderEvaluation<String> {
        try getEvaluation(
            key: key, defaultValue: defaultValue, context: context,
            extract: { $0.string })
    }

    func getIntegerEvaluation(
        key: String,
        defaultValue: Int64,
        context: EvaluationContext?
    ) throws -> OpenFeature.ProviderEvaluation<Int64> {
        return try getEvaluation(
            key: key, defaultValue: defaultValue, context: context,
            extract: { value in
                guard let int = value.int else { return nil }
                return Int64(int)
            })
    }

    func getDoubleEvaluation(
        key: String,
        defaultValue: Double,
        context: EvaluationContext?
    ) throws -> OpenFeature.ProviderEvaluation<Double> {
        return try getEvaluation(
            key: key, defaultValue: defaultValue, context: context,
            extract: { value in
                guard let doubleValue = value.double else { return nil }
                return Double(doubleValue)
            })
    }
    
    func getObjectEvaluation(
        key: String,
        defaultValue: OpenFeature.Value,
        context: EvaluationContext?
    ) throws -> OpenFeature.ProviderEvaluation<OpenFeature.Value> {
        try getEvaluation(
            key: key,
            defaultValue: defaultValue,
            context: context,
            extract: { codableValue in
                return codableValue
                    .unwrapJSONStringIfNeeded()
                    .toOpenFeatureValue()
            }
        )
    }

    private func getEvaluation<T>(
        key: String,
        defaultValue: T,
        context: EvaluationContext?,
        extract: (CodableValue) -> T?
    ) throws -> ProviderEvaluation<T> {
        LoggerManager.shared.info("get\(String(describing: T.self)) Evaluation: key: \(key), targetingId: \(String(describing: context?.getTargetingKey()))")
        
        guard let cachedResponse = evaluationCache.evaluationResponse else {
            return ProviderEvaluation(
                value: defaultValue,
                errorCode:
                    OpenFeatureError
                    .generalError(
                        message: "Could not retrieve evaluation response"
                    )
                    .errorCode(),
                errorMessage: "Evaluation Response could not be retrieved")
        }
        
        // now that we have a response and if its expired fire the event that will trigger an update to Evaluate
        if evaluationCache.isExpired() {
            let providerEvent = ProviderEvent.stale
            eventHandler.send(providerEvent)
        }
        
        guard let context,
              context.getTargetingKey() == cachedResponse.targetingKey
        else {
            return ProviderEvaluation(
                value: defaultValue,
                errorCode: OpenFeatureError.invalidContextError
                    .errorCode(),
                errorMessage: OpenFeatureError.invalidContextError
                    .localizedDescription)
        }

        guard let toggle = cachedResponse.toggles[key] else {
            return ProviderEvaluation(
                value: defaultValue,
                errorCode:
                    OpenFeatureError
                    .flagNotFoundError(key: key)
                    .errorCode())
        }

        if let flagValue = extract(toggle.value) {
            return ProviderEvaluation(value: flagValue, reason: toggle.reason)
        } else {
            return ProviderEvaluation(
                value: defaultValue,
                errorCode:
                    OpenFeatureError
                    .parseError(message: "Could not extract the value")
                    .errorCode())
        }
    }
}

extension CodableValue {
    public func toOpenFeatureValue() -> OpenFeature.Value {
        switch self {
        case .string(let v):
            return .string(v)
        case .int(let v):
            return .integer(Int64(v))
        case .double(let v):
            return .double(v)
        case .bool(let v):
            return .boolean(v)
        case .array(let arr):
            return .list(arr.map { $0.toOpenFeatureValue() })
        case .dictionary(let dict):
            return .structure(dict.mapValues { $0.toOpenFeatureValue() })
        case .null:
            return .null
        }
    }
}
