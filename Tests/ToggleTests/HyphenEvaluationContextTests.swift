import Testing
import Foundation
import OpenFeature
@testable import Toggle

struct HyphenEvaluationContextTests {
    @Test
    func testHyphenEvaluationContextFromEvaluationContext() throws {
        let context = MockEvaluationContext(
            targetingKey: "user-123",
            values: [
                "CustomAttributes": .structure([
                    "theme": .string("dark"),
                    "betaAccess": .boolean(true)
                ]),
                "User": .structure([
                    "Email": .string("mock@example.com"),
                    "Name": .string("Tester"),
                    "CustomAttributes": .structure([
                        "subscription": .string("pro")
                    ])
                ])
            ]
        )
        
        let hyphen = try #require(HyphenEvaluationContext.from(context: context, application: "mock-application", environment: "mock-environment"))
        
        #expect("user-123" == hyphen.targetingKey)
        #expect("dark" == hyphen.customAttributes["theme"]?.string)
        #expect("mock@example.com" == hyphen.user?.email)
    }
    
    @Test
    func testApplicationIsPresent() {
        let context = HyphenEvaluationContext.mock
        #expect(false == context.application.isEmpty, "Bundle Identifier should not be empty")
    }
    
    @Test
    func testEnvironmentIsPresent() {
        let context = HyphenEvaluationContext.mock
        #expect(false == context.environment.isEmpty, "Environment should not be empty")
    }
    
    @Test
    func testBuildVersionIsPresentIfAvailable() throws {
        let context = HyphenEvaluationContext.mock
        let buildVersion = try #require(context.customAttributes["buildVersion"])
        #expect(false == buildVersion.string!.isEmpty, "Build version should be present if available in Info.plist")
    }
    
    @Test
    func testAppVersionIsPresentIfAvailable() throws {
        let context = HyphenEvaluationContext.mock
        let appVersion = try #require(context.customAttributes["appVersion"])
        #expect(false == appVersion.string!.isEmpty, "App version should be present if available in Info.plist")
    }
}

