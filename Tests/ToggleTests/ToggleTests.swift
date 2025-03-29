//
//  ToggleTests.swift
//  ToggleTests
//
//  Created by Jim Newkirk on 3/17/25.
//
import Testing
import Foundation
import OpenFeature
@testable import Toggle

@Suite(.serialized)
struct ToggleTests {
    static let configuration = HyphenConfiguration(using: EnvironmentVars.togglePublicKey, application: "hyphen-example-app", environment: "development")
    
    @Test
    func testSingletonPersists() {
        #expect(OpenFeatureAPI.shared === OpenFeatureAPI.shared)
    }
    
    @Test
    func testApiSetsProvider() async throws {
        let provider = HyphenProvider(using: Self.configuration)
        await OpenFeatureAPI.shared.setProviderAndWait(provider: provider)
        let setProvider = try #require(OpenFeatureAPI.shared.getProvider() as? HyphenProvider)
        #expect(setProvider.metadata.name == provider.metadata.name)
    }
    
    @Test
    func testProviderMetadata() async {
        let provider = HyphenProvider(using: Self.configuration)
        await OpenFeatureAPI.shared.setProviderAndWait(provider: provider)
        #expect((OpenFeatureAPI.shared.getProvider() as? HyphenProvider)?.metadata.name == provider.metadata.name)
    }
    
    @Test
    func testNamedClient() {
        let client = OpenFeatureAPI.shared.getClient(name: "test", version: nil)
        #expect((client as? OpenFeatureClient)?.metadata.name == "test")
    }
    
    struct MatchingEvaluationTests {
        let provider: HyphenProvider
        let client: Client
        
        internal init() async {
            self.provider = HyphenProvider(using: ToggleTests.configuration)
            let context = MutableContext(targetingKey: UUID().uuidString)
            await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
            
            self.client = OpenFeatureAPI.shared.getClient()
        }
        
        @Test
        func testBoolEvaluation() {
            let flagDetails: FlagEvaluationDetails<Bool> = client.getDetails(
                key: "bool-toggle", defaultValue: false)
            
            #expect(true == flagDetails.value)
            #expect("matched target 0" == flagDetails.reason)
        }
        
        @Test
        func testInvalidBoolToggle() {
            let flagDetails: FlagEvaluationDetails<Bool> = client.getDetails(
                key: "invalid-toggle", defaultValue: false)
            #expect(false == flagDetails.value)
            #expect(ErrorCode.flagNotFound == flagDetails.errorCode, "This should be flag not found")
        }
        
        @Test
        func testIntegerEvaluation() {
            let flagDetails: FlagEvaluationDetails<Int64> = client.getDetails(
                key: "number-toggle", defaultValue: 20
            )
            #expect(84 == flagDetails.value)
            #expect("matched target 0" == flagDetails.reason)
        }
        
        @Test
        func testDoubleEvaluation() {
            let flagDetails: FlagEvaluationDetails<Int64> = client.getDetails(
                key: "double-toggle", defaultValue: 20
            )
            #expect(60 == flagDetails.value)
            #expect("matched target 0" == flagDetails.reason)
        }
        
        @Test
        func testStringEvaluation() {
            let client = OpenFeatureAPI.shared.getClient()
            let flagDetails = client.getDetails(key: "string-toggle", defaultValue: "test")
            #expect("hyphen-example-app-flag" == flagDetails.value)
            #expect("matched target 0" == flagDetails.reason)
        }
        
        @Test
        func testObjectEvaluation() {
            let defaultValue: OpenFeature.Value = .structure([
                "name": .string("Taylor"),
                "age": .integer(29),
                "isActive": .boolean(true)
            ])
            
            let expectedValue: OpenFeature.Value = .structure([
                "name": .string("Trent"),
                "age": .integer(58),
                "isActive": .boolean(false)
            ])

            let client = OpenFeatureAPI.shared.getClient()
            let flagDetails = client.getDetails(key: "json-toggle", defaultValue: defaultValue)
            #expect(expectedValue == flagDetails.value)
            #expect("matched target 0" == flagDetails.reason)
        }
    }
    
    struct NoMatchingCriteriaEvaluationTests {
        static let configuration = HyphenConfiguration(using: EnvironmentVars.togglePublicKey, application: "app-not-defined", environment: "development")
        let provider: HyphenProvider
        let client: Client
        
        internal init() async {
            self.provider = HyphenProvider(using: Self.configuration)
            let context = MutableContext(targetingKey: UUID().uuidString)
            await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
            
            self.client = OpenFeatureAPI.shared.getClient()
        }
        
        @Test
        func testBoolEvaluation() {
            let flagDetails: FlagEvaluationDetails<Bool> = client.getDetails(
                key: "bool-toggle", defaultValue: false)
            
            #expect(false == flagDetails.value)
            #expect("no target matched" == flagDetails.reason)
        }
        
        @Test
        func testIntegerEvaluation() {
            let flagDetails: FlagEvaluationDetails<Int64> = client.getDetails(
                key: "number-toggle", defaultValue: 21)
            
            #expect(21 == flagDetails.value)
            #expect("no target matched" == flagDetails.reason)
        }
        
        @Test
        func testDoubleToggle() {
            let client = OpenFeatureAPI.shared.getClient()
            let flagDetails = client.getDetails(key: "double-toggle", defaultValue: 2.0)
            #expect(2.0 == flagDetails.value)
            #expect("no target matched" == flagDetails.reason)
        }

        @Test
        func testStringEvaluation() {
            let client = OpenFeatureAPI.shared.getClient()
            let flagDetails = client.getDetails(key: "string-toggle", defaultValue: "test")
            #expect("test" == flagDetails.value)
            #expect("no target matched" == flagDetails.reason)
        }
    }
}
