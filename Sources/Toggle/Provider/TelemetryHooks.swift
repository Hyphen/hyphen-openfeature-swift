import Foundation
import OpenFeature

struct HookFactory {
    let service: HyphenService
    
    static func makeHook(for type: FlagValueType, service: HyphenService) -> any Hook {
        switch type {
        case .boolean: return BoolHook(service: service)
        case .string: return StringHook(service: service)
        case .integer: return IntHook(service: service)
        case .double: return DoubleHook(service: service)
        case .object: return ObjectHook(service: service)
        @unknown default:
            LoggerManager.shared.error("Unsupported hook type")
        }
    }
}

class BoolHook: Hook {
    internal init(service: HyphenService) {
        self.service = service
    }
    
    typealias HookValue = Bool
    
    private let service: HyphenService

    func after<HookValue>(
        ctx: HookContext<HookValue>,
        details: FlagEvaluationDetails<HookValue>,
        hints: [String: Any]
    ) {
        HookTelemetryHelper.sendTelemetry(using: service, hookContext: ctx, details: details)
    }
}

class StringHook: Hook {
    internal init(service: HyphenService) {
        self.service = service
    }
    
    typealias HookValue = String
    
    private let service: HyphenService

    func after<HookValue>(
        ctx: HookContext<HookValue>,
        details: FlagEvaluationDetails<HookValue>,
        hints: [String: Any]
    ) {
        HookTelemetryHelper.sendTelemetry(using: service, hookContext: ctx, details: details)
    }
}

class IntHook: Hook {
    internal init(service: HyphenService) {
        self.service = service
    }
    
    typealias HookValue = Int64
    
    private let service: HyphenService

    func after<HookValue>(
        ctx: HookContext<HookValue>,
        details: FlagEvaluationDetails<HookValue>,
        hints: [String: Any]
    ) {
        HookTelemetryHelper.sendTelemetry(using: service, hookContext: ctx, details: details)
    }
}

class DoubleHook: Hook {
    internal init(service: HyphenService) {
        self.service = service
    }
    
    typealias HookValue = Double
    
    private let service: HyphenService

    func after<HookValue>(
        ctx: HookContext<HookValue>,
        details: FlagEvaluationDetails<HookValue>,
        hints: [String: Any]
    ) {
        HookTelemetryHelper.sendTelemetry(using: service, hookContext: ctx, details: details)
    }
}

class ObjectHook: Hook {
    internal init(service: HyphenService) {
        self.service = service
    }
    
    typealias HookValue = OpenFeature.Value
    
    private let service: HyphenService

    func after<HookValue>(
        ctx: HookContext<HookValue>,
        details: FlagEvaluationDetails<HookValue>,
        hints: [String: Any]
    ) {
        HookTelemetryHelper.sendTelemetry(using: service, hookContext: ctx, details: details)
    }
}
