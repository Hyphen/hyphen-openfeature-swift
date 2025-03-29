//
//  ApiClientOptions.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/28/25.
//
import Foundation

public struct NetworkOptions: Equatable, Hashable {
    public var useCellularAccess: Bool
    public var timeout: TimeInterval
    public var maxRetries: Int
    public var retryDelay: TimeInterval

    public init(
        useCellularAccess: Bool = true,
        timeout: TimeInterval = 10,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 0.5
    ) {
        self.useCellularAccess = useCellularAccess
        self.timeout = timeout
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }
}
