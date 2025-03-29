//
//  HyphenUrls.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/25/25.
//
import Foundation
import SimpleLogger

public struct HyphenUrls {
    private var logger: LoggerManagerProtocol = {
        .default(
            subsystem: "hyphen-provider-swift",
            category: String(describing: Self.self)
        )
    }()
    
    public static let evaluationPath = "toggle/evaluate"
    public static let telemetryPath = "toggle/telemetry"

    public let publicKey: PublicKey
    public let customUrls: [URL]

    public init(publicKey: String, customUrls: [URL] = []) {
        self.publicKey = PublicKey(publicKey)
        self.customUrls = customUrls
    }

    public var evaluationUrls: [URL] {
        if customUrls.isEmpty {
            return makeUrls(for: publicKey, path: Self.evaluationPath)
        } else {
            return appendPath(Self.evaluationPath, to: customUrls)
        }
    }

    public var telemetryUrls: [URL] {
        if customUrls.isEmpty {
            return makeUrls(for: publicKey, path: Self.telemetryPath)
        } else {
            return appendPath(Self.telemetryPath, to: customUrls)
        }
    }

    private func makeUrls(for publicKey: PublicKey, path: String) -> [URL] {
        var urls: [URL] = []

        if let orgId = publicKey.orgId {
            let orgUrlString = "https://\(orgId).toggle.hyphen.cloud/\(path)"
            if let orgUrl = URL(string: orgUrlString) {
                urls.append(orgUrl)
            }
        }

        if let backupUrl = URL(string: "https://toggle.hyphen.cloud/\(path)") {
            urls.append(backupUrl)
        }

        return urls
    }

    private func appendPath(_ path: String, to baseUrls: [URL]) -> [URL] {
        let knownPaths = [Self.evaluationPath, Self.telemetryPath]

        return baseUrls.compactMap { url in
            var cleanedUrl = url

            for knownPath in knownPaths {
                if url.path.hasSuffix("/\(knownPath)") {
                    logger.warning(
                        "[HyphenUrls] Custom URL '\(url)' includes known path '\(knownPath)'. Trimming it before appending '\(path)'."
                    )

                    if let trimmed = URL(string: url.absoluteString.replacingOccurrences(of: "/\(knownPath)", with: "")) {
                        cleanedUrl = trimmed
                    }
                    break
                }
            }

            return cleanedUrl.appendingPathComponent(path)
        }
    }
}



