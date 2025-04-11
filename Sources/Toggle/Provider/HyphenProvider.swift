//
//  HyphenProvider.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/17/25.
//

import OpenFeature
import Foundation
import Network
import Combine
import SimpleLogger

public struct HyphenMetadata: ProviderMetadata {
    public var name: String? = PackageConstants.subsystem
}

public final class HyphenProvider: FeatureProvider {
    private lazy var logger: LoggerManagerProtocol = {
        .default(
            subsystem: PackageConstants.subsystem,
            category: String(describing: Self.self)
        )
    }()
    
    public init(using configuration: HyphenConfiguration, hooks: [any OpenFeature.Hook] = [], apiClient: ApiClientProtocol = ApiClient()) {
        self.metadata = HyphenMetadata()
        self.eventHandler = EventHandler()
        self.configuration = configuration
        
        let service = HyphenService(using: configuration, apiClient: apiClient, eventHandler: eventHandler)
        self.hyphenService = service
        
        self.hooks = hooks
        self.hooks.append(HookFactory.makeHook(for: .boolean, service: service))
        self.hooks.append(HookFactory.makeHook(for: .string, service: service))
        self.hooks.append(HookFactory.makeHook(for: .integer, service: service))
        self.hooks.append(HookFactory.makeHook(for: .double, service: service))
        self.hooks.append(HookFactory.makeHook(for: .object, service: service))
        
        self.startInternalMonitoring()
    }

    let configuration: HyphenConfiguration
    public var hooks: [any OpenFeature.Hook]
    public let metadata: OpenFeature.ProviderMetadata
    private var hyphenService: HyphenService
    private let eventHandler: EventHandler
    private var cancellables = Set<AnyCancellable>()
    private let contextQueue = DispatchQueue(label: "ai.hyphen.contextQueue")
    private var _lastContext: EvaluationContext?

    var lastContext: EvaluationContext? {
        get {
            contextQueue.sync {
                _lastContext
            }
        }
        set {
            contextQueue.async(flags: .barrier) {
                self._lastContext = newValue
            }
        }
    }
    
    public func initialize(initialContext: EvaluationContext?) async throws {
        logger.info("initialize: initialContext: \(String(describing: initialContext?.getTargetingKey()))")
        
        try await evaluate(initialContext)
    }
    
    public func onContextSet(oldContext: EvaluationContext?, newContext: EvaluationContext) async throws {
        logger.info("onCentextSet: old: \(String(describing: oldContext?.getTargetingKey()))")
        logger.info("onCentextSet: new: \(newContext.getTargetingKey())")
        
        try await evaluate(newContext)
    }
    
    public func getBooleanEvaluation(key: String,
                              defaultValue: Bool,
                              context: EvaluationContext?) throws -> OpenFeature.ProviderEvaluation<Bool> {
        logger.info("getBooleanEvaluation: key: \(key), targetingId: context: \(String(describing: context?.getTargetingKey()))")
        
        do {
            return try hyphenService.getBooleanEvaluation(key: key, defaultValue: defaultValue, context: context)
        } catch {
            return ProviderEvaluation(value: defaultValue, errorCode: ErrorCode.providerFatal, errorMessage: error.localizedDescription)
        }
    }
    
    public func getStringEvaluation(key: String, defaultValue: String, context: (any OpenFeature.EvaluationContext)?) throws -> OpenFeature.ProviderEvaluation<String> {
        do {
            return try hyphenService.getStringEvaluation(key: key, defaultValue: defaultValue, context: context)
        } catch {
            return ProviderEvaluation(value: defaultValue, errorCode: ErrorCode.providerFatal, errorMessage: error.localizedDescription)
        }
    }
    
    public func getIntegerEvaluation(key: String, defaultValue: Int64, context: (any OpenFeature.EvaluationContext)?) throws -> OpenFeature.ProviderEvaluation<Int64> {
        do {
            return try hyphenService.getIntegerEvaluation(key: key, defaultValue: defaultValue, context: context)
        } catch {
            return ProviderEvaluation(value: defaultValue, errorCode: ErrorCode.providerFatal, errorMessage: error.localizedDescription)
        }
    }
    
    public func getDoubleEvaluation(key: String, defaultValue: Double, context: (any OpenFeature.EvaluationContext)?) throws -> OpenFeature.ProviderEvaluation<Double> {
        do {
            return try hyphenService.getDoubleEvaluation(key: key, defaultValue: defaultValue, context: context)
        } catch {
            return ProviderEvaluation(value: defaultValue, errorCode: ErrorCode.providerFatal, errorMessage: error.localizedDescription)
        }
    }
    
    public func getObjectEvaluation(key: String, defaultValue: OpenFeature.Value, context: (any OpenFeature.EvaluationContext)?) throws -> OpenFeature.ProviderEvaluation<OpenFeature.Value> {
        do {
            return try hyphenService.getObjectEvaluation(key: key, defaultValue: defaultValue, context: context)
        } catch {
            return ProviderEvaluation(value: defaultValue, errorCode: ErrorCode.providerFatal, errorMessage: error.localizedDescription)
        }
    }
    
    public func observe() -> AnyPublisher<ProviderEvent?, Never> {
        eventHandler.observe()
    }
    
    private func startInternalMonitoring() {
        eventHandler.observe()
            .compactMap { $0 }
            .sink { [weak self] event in
                guard let self else { return }

                logger.info("Observed internal event: \(event)")

                if event == .stale {
                    logger.info("Handling stale event: triggering evaluate")

                    Task.detached {
                        try? await self.evaluate(self.lastContext)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func evaluate(_ context: EvaluationContext?) async throws {
        try await hyphenService.evaluate(with: context)
        self.lastContext = context
        
        let providerEvent = ProviderEvent.contextChanged
        eventHandler.send(providerEvent)
    }
}







