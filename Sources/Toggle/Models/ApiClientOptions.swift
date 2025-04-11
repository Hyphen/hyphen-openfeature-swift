import Foundation

public struct NetworkOptions: Equatable, Hashable {
    public let useCellularAccess: Bool
    public let timeout: TimeInterval
    public let maxRetries: Int
    public let retryDelay: TimeInterval
    public let cacheExpiration: TimeInterval

    public init(
        useCellularAccess: Bool = true,
        timeout: TimeInterval = 10,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 0.5,
        cacheExpiration: TimeInterval = 15 * 60
    ) {
        self.useCellularAccess = useCellularAccess
        self.timeout = timeout
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
        self.cacheExpiration = cacheExpiration
    }
}
