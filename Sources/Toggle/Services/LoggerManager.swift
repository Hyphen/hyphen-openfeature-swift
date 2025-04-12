import Foundation
import os

protocol LoggerProtocol {
    func debug(_ message: @escaping () -> String)
    func info(_ message: @escaping () -> String)
    func error(_ message: @escaping () -> String)
}

struct OSLogger: LoggerProtocol {
    private let logger: Logger

    public init(subsystem: String = Bundle.main.bundleIdentifier ?? PackageConstants.subsystem,
                category: String = "Toggle") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func debug(_ message: @escaping () -> String) {
        logger.debug("\(message())")
    }

    public func info(_ message: @escaping () -> String) {
        logger.info("\(message())")
    }

    public func error(_ message: @escaping () -> String) {
        logger.error("\(message())")
    }
}

extension LoggerProtocol {
    func debug(_ message: String) {
        debug { message }
    }

    func info(_ message: String) {
        info { message }
    }

    func error(_ message: String) {
        error { message }
    }
}

enum LoggerManager {
    public static var shared: LoggerProtocol = OSLogger()

    public static func configure(_ logger: LoggerProtocol) {
        LoggerManager.shared = logger
    }
}
