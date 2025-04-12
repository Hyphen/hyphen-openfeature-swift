import Foundation
import os

public protocol LoggerProtocol {
    func debug(_ message: @autoclosure () -> String)
    func info(_ message: @autoclosure () -> String)
    func error(_ message: @autoclosure () -> String)
}

public struct OSLogger: LoggerProtocol {
    private let logger: os.Logger

    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "Default", category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func debug(_ message: @autoclosure () -> String) {
        logger.debug("\(message())")
    }

    public func info(_ message: @autoclosure () -> String) {
        logger.info("\(message())")
    }

    public func error(_ message: @autoclosure () -> String) {
        logger.error("\(message())")
    }
}

public struct LoggerManager {
    public static var shared: LoggerProtocol = OSLogger(category: "Toggle")
}
