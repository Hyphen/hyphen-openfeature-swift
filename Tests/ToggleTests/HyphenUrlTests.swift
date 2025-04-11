import Testing
import Foundation
@testable import Toggle

struct HyphenUrlTests {
    @Test
    func customUrls() throws {
        let validRaw = "org-123:extra-data"
        let encoded = Data(validRaw.utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let url = URL(string: "https://example.com")!
        let config = HyphenConfiguration(using: key, application: "app", environment: "env", customUrls: [url], enableToggleUsage: false)
        
        let evaluateResult = config.evaluationUrls
        try #require(evaluateResult.count == 1)
        #expect("https://example.com/toggle/evaluate" == evaluateResult[0].absoluteString)
        
        let telemetryResult = config.telemetryUrls
        try #require(telemetryResult.count == 1)
        #expect("https://example.com/toggle/telemetry" == telemetryResult[0].absoluteString)
    }
    
    @Test
    func customUrlsWithAppendedPath() throws {
        let validRaw = "org-123:extra-data"
        let encoded = Data(validRaw.utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let url = URL(string: "https://example.com/toggle/evaluate")!
        let config = HyphenConfiguration(using: key, application: "app", environment: "env", customUrls: [url], enableToggleUsage: false)
        
        let result = config.evaluationUrls
        try #require(result.count == 1)
        #expect("https://example.com/toggle/evaluate" == result[0].absoluteString)
        
        let telemetryResult = config.telemetryUrls
        try #require(telemetryResult.count == 1)
        #expect("https://example.com/toggle/telemetry" == telemetryResult[0].absoluteString)
    }
    
    @Test
    func customUrlWithTrailingSlash() throws {
        let validRaw = "org-123:extra-data"
        let encoded = Data(validRaw.utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let url = URL(string: "https://example.com/")!
        let config = HyphenConfiguration(using: key, application: "app", environment: "env", customUrls: [url], enableToggleUsage: false)
        let result = config.evaluationUrls

        try #require(result.count == 1)
        #expect("https://example.com/toggle/evaluate" == result[0].absoluteString)
    }
    
    @Test
    func customUrlWithPartialPath() throws {
        let validRaw = "org-123:extra-data"
        let encoded = Data(validRaw.utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let url = URL(string: "https://example.com/toggle")!
        let config = HyphenConfiguration(using: key, application: "app", environment: "env", customUrls: [url], enableToggleUsage: false)
        let result = config.evaluationUrls

        try #require(result.count == 1)
        #expect("https://example.com/toggle/toggle/evaluate" == result[0].absoluteString)
    }
    
    @Test
    func multipleCustomUrls() throws {
        let validRaw = "org-123:extra-data"
        let encoded = Data(validRaw.utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let urls = [
            URL(string: "https://one.com")!,
            URL(string: "https://two.com/toggle/evaluate")!
        ]
        let config = HyphenConfiguration(using: key, application: "app", environment: "env", customUrls: urls, enableToggleUsage: false)
        let result = config.evaluationUrls

        try #require(result.count == 2)
        #expect("https://one.com/toggle/evaluate" == result[0].absoluteString)
        #expect("https://two.com/toggle/evaluate" == result[1].absoluteString)
    }

    @Test
    func evaluateUrlsValidOrgId() throws {
        let validRaw = "org-123:extra-data"
        let encoded = Data(validRaw.utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let config = HyphenConfiguration(using: key, application: "app", environment: "env", enableToggleUsage: false)
        let result = config.evaluationUrls

        try #require(result.count == 2)
        #expect("https://org-123.toggle.hyphen.cloud/toggle/evaluate" == result[0].absoluteString)
        #expect("https://toggle.hyphen.cloud/toggle/evaluate" == result[1].absoluteString)
    }

    @Test
    func evaluteUrlsInvalidOrgId() throws {
        let encoded = Data("missingcolonvalue".utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let config = HyphenConfiguration(using: key, application: "app", environment: "env", enableToggleUsage: false)
        let result = config.evaluationUrls

        try #require(result.count == 1)
        #expect("https://toggle.hyphen.cloud/toggle/evaluate" == result[0].absoluteString)
    }
    
    @Test
    func telemetryUrlsValidOrgId() throws {
        let validRaw = "org-123:extra-data"
        let encoded = Data(validRaw.utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let config = HyphenConfiguration(using: key, application: "app", environment:  "env", enableToggleUsage: false)
        let result = config.telemetryUrls

        try #require(result.count == 2)
        #expect("https://org-123.toggle.hyphen.cloud/toggle/telemetry" == result[0].absoluteString)
        #expect("https://toggle.hyphen.cloud/toggle/telemetry" == result[1].absoluteString)
    }

    @Test
    func telemetryUrlsInvalidOrgId() throws {
        let encoded = Data("missingcolonvalue".utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let config = HyphenConfiguration(using: key, application: "app", environment:  "env", enableToggleUsage: false)
        let result = config.telemetryUrls

        try #require(result.count == 1)
        #expect("https://toggle.hyphen.cloud/toggle/telemetry" == result[0].absoluteString)
    }
    
    @Test
    func malformedPublicKeyFallsBack() throws {
        let key = "public_NOT_BASE64!"

        let config = HyphenConfiguration(using: key, application: "app", environment:  "env", enableToggleUsage: false)
        let result = config.evaluationUrls

        try #require(result.count == 1)
        #expect("https://toggle.hyphen.cloud/toggle/evaluate" == result[0].absoluteString)
    }
}
