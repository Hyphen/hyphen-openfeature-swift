//
//  HookTelemetryHelper.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/28/25.
//
import Foundation
@preconcurrency import OpenFeature

struct HookTelemetryHelper {
   private init() { }
    
    static func sendTelemetry<HookValue>(
        using service: HyphenService,
        hookContext: HookContext<HookValue>,
        details: FlagEvaluationDetails<HookValue>
    ) {
        print("🟢 Hook AFTER evaluation for flag: \(hookContext.flagKey), result: \(details.value)")
        
        guard let evaluationContext = hookContext.ctx else {
            LoggerManager.shared.error("In - afterHook - evaluationContext is nil")
            return
        }
        
        Task {
            await service.telemetry(evaluationContext: evaluationContext, details: details)
        }
    }
}
