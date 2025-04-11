import Testing
import Foundation
import OpenFeature
@testable import Toggle

@Suite(.serialized)
struct HyphenProviderTests {
    struct ToggleKey {
        static let bool = "bool-toggle"
        static let number = "number-toggle"
        static let double = "double-toggle"
        static let string = "string-toggle"
        static let json = "json-toggle"
    }
    
    @Suite(.serialized)
    struct SetProviderTests {
        static let configuration = HyphenConfiguration(using: "project-public-key",
                                                       application: "hyphen-example-app",
                                                       environment: "development",
                                                       enableToggleUsage: false)
        
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
    }
    
    @Suite(.serialized)
    struct MatchingEvaluationTests {
        static let configuration = HyphenConfiguration(using: "project-public-key",
                                                       application: "hyphen-example-app",
                                                       environment: "development",
                                                       enableToggleUsage: false)
        
        static let targetingKey = "hyphen-targetingKey"
        static let commonReason = "Matched"
        
        static let jsonObject: OpenFeature.Value = .structure([
            "name": .string("Taylor"),
            "age": .integer(29),
            "isActive": .boolean(true)
        ])
        
        let provider: HyphenProvider
        let client: Client
        
        internal init() async {
            let response = EvaluationResponse.mock(
                targetingKey: Self.targetingKey,
                evaluations: [
                    .mock(key: ToggleKey.bool, value: .bool(true), reason: Self.commonReason),
                    .mock(key: ToggleKey.number, value: .int(84), reason: Self.commonReason),
                    .mock(key: ToggleKey.double, value: .double(23), reason: Self.commonReason),
                    .mock(key: ToggleKey.string, value: .string("string-result"), reason: Self.commonReason),
                    .mock(key: ToggleKey.json, value: CodableValue(any: Self.jsonObject.toAny()), reason: Self.commonReason)
                ]
            )
            
            let mockClient = MockApiClient()
            mockClient.evaluationResponse = response
            
            self.provider = HyphenProvider(using: Self.configuration, apiClient: mockClient)
            let context = MutableContext(targetingKey: Self.targetingKey)
            await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
            
            self.client = OpenFeatureAPI.shared.getClient()
        }
        
        @Test
        func testBoolEvaluation() async throws {
            let flagDetails: FlagEvaluationDetails<Bool> = client.getDetails(
                key: ToggleKey.bool, defaultValue: false)
            
            #expect(true == flagDetails.value)
            #expect(Self.commonReason == flagDetails.reason)
        }
        
        @Test
        func testIntegerEvaluation() {
            let flagDetails: FlagEvaluationDetails<Int64> = client.getDetails(
                key: ToggleKey.number, defaultValue: 20)
            
            #expect(84 == flagDetails.value)
            #expect(Self.commonReason == flagDetails.reason)
        }
        
        @Test
        func testDoubleEvaluation() {
            let flagDetails: FlagEvaluationDetails<Double> = client.getDetails(
                key: ToggleKey.double, defaultValue: 20)
            
            #expect(23.0 == flagDetails.value)
            #expect(Self.commonReason == flagDetails.reason)
        }
        
        @Test
        func testStringEvaluation() {
            let flagDetails = client.getDetails(key: ToggleKey.string, defaultValue: "test")
            
            #expect("string-result" == flagDetails.value)
            #expect(Self.commonReason == flagDetails.reason)
        }
        
        @Test
        func testObjectEvaluation() {
            let defaultValue: OpenFeature.Value = .structure([
                "name": .string("Trent"),
                "age": .integer(58),
                "isActive": .boolean(false)
            ])

            let client = OpenFeatureAPI.shared.getClient()
            let flagDetails = client.getDetails(key: ToggleKey.json, defaultValue: defaultValue)
            #expect(Self.jsonObject == flagDetails.value)
            #expect(Self.commonReason == flagDetails.reason)
        }
    }
    
    @Suite(.serialized)
    struct InvalidToggleKeyTests {
        static let configuration = HyphenConfiguration(using: "project-public-key",
                                                       application: "hyphen-example-app",
                                                       environment: "development",
                                                       enableToggleUsage: false)
        
        static let targetingKey = "hyphen-targetingKey"
        static let commonReason = "Matched"
        
        static let jsonObject: OpenFeature.Value = .structure([
            "name": .string("Taylor"),
            "age": .integer(29),
            "isActive": .boolean(true)
        ])
        
        let provider: HyphenProvider
        let client: Client
        
        internal init() async {
            let response = EvaluationResponse.mock(
                targetingKey: Self.targetingKey,
                evaluations: [
                    .mock(key: ToggleKey.bool, value: .bool(true), reason: Self.commonReason),
                    .mock(key: ToggleKey.number, value: .int(84), reason: Self.commonReason),
                    .mock(key: ToggleKey.double, value: .double(23), reason: Self.commonReason),
                    .mock(key: ToggleKey.string, value: .string("string-result"), reason: Self.commonReason),
                    .mock(key: ToggleKey.json, value: CodableValue(any: Self.jsonObject.toAny()), reason: Self.commonReason)
                ]
            )
            
            let mockClient = MockApiClient()
            mockClient.evaluationResponse = response
            
            self.provider = HyphenProvider(using: Self.configuration, apiClient: mockClient)
            let context = MutableContext(targetingKey: Self.targetingKey)
            await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
            
            self.client = OpenFeatureAPI.shared.getClient()
        }
        
        @Test
        func invalidKeyBoolEvaluation() {
            let flagDetails: FlagEvaluationDetails<Bool> = client.getDetails(
                key: "invalid-toggle", defaultValue: false)
            
            #expect(false == flagDetails.value)
            #expect(ErrorCode.flagNotFound == ErrorCode.flagNotFound, "This should be flag not found")
        }
        
        @Test
        func invalidKeyIntegerEvaluation() {
            let flagDetails: FlagEvaluationDetails<Int64> = client.getDetails(
                key: "invalid-toggle", defaultValue: 20)
            
            #expect(20 == flagDetails.value)
            #expect(ErrorCode.flagNotFound == ErrorCode.flagNotFound, "This should be flag not found")
        }
        
        @Test
        func invalidKeyDoubleEvaluation() {
            let flagDetails: FlagEvaluationDetails<Double> = client.getDetails(
                key: "invalid-toggle", defaultValue: 40.0)
            
            #expect(40.0 == flagDetails.value)
            #expect(ErrorCode.flagNotFound == ErrorCode.flagNotFound, "This should be flag not found")
        }
        
        @Test
        func invalidKeyStringEvaluation() {
            let flagDetails = client.getDetails(key: "invalid-toggle", defaultValue: "test")
            
            #expect("test" == flagDetails.value)
            #expect(ErrorCode.flagNotFound == ErrorCode.flagNotFound, "This should be flag not found")
        }
        
        @Test
        func invalidKeyJSONEvaluation() {
            let defaultValue: OpenFeature.Value = .structure([
                "name": .string("Trent"),
                "age": .integer(58),
                "isActive": .boolean(false)
            ])

            let client = OpenFeatureAPI.shared.getClient()
            let flagDetails = client.getDetails(key: "invalid-toggle", defaultValue: defaultValue)
            #expect(defaultValue == flagDetails.value)
            #expect(ErrorCode.flagNotFound == ErrorCode.flagNotFound, "This should be flag not found")
        }
    }

    @Suite(.serialized)
    struct MismatchTargetingKeyTests {
        static let configuration = HyphenConfiguration(using: "project-public-key",
                                                       application: "hyphen-example-app",
                                                       environment: "development",
                                                       enableToggleUsage: false)
        
        static let targetingKey = "hyphen-targetingKey"
        
        let provider: HyphenProvider
        let client: Client
        
        internal init() async {
            let response = EvaluationResponse.mock(
                targetingKey: Self.targetingKey,
                evaluations: [
                    .mock(key: "bool-toggle", value: .bool(true), reason: "reason")
                ])
        
            let mockClient = MockApiClient()
            mockClient.evaluationResponse = response
            
            self.provider = HyphenProvider(using: Self.configuration, apiClient: mockClient)
            let context = MutableContext(targetingKey: UUID().uuidString)
            await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
            
            self.client = OpenFeatureAPI.shared.getClient()
        }
        
        @Test
        func MismatchTargetingKey() async {
            let newContext = MutableContext(targetingKey: UUID().uuidString)
            await OpenFeatureAPI.shared.setEvaluationContextAndWait(evaluationContext: newContext)
            
            let flagDetails: FlagEvaluationDetails<Bool> = client.getDetails(
                key: "bool-toggle", defaultValue: false)
            
            #expect(false == flagDetails.value)
            #expect(ErrorCode.invalidContext == flagDetails.errorCode)
            #expect("The operation couldn’t be completed. (OpenFeature.OpenFeatureError error 4.)" ==
                    flagDetails.errorMessage)
        }
    }
    
    
    @Suite(.serialized)
    struct NoEvaluationResponseError {
        static let configuration = HyphenConfiguration(using: "project-public-key",
                                                       application: "hyphen-example-app",
                                                       environment: "development",
                                                       enableToggleUsage: false)
        
        let provider: HyphenProvider
        let client: Client
        
        internal init() async {
            let mockClient = MockApiClient()
            mockClient.evaluationResponse = nil
            
            self.provider = HyphenProvider(using: Self.configuration, apiClient: mockClient)
            let context = MutableContext(targetingKey: UUID().uuidString)
            await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
            
            self.client = OpenFeatureAPI.shared.getClient()
        }
        
        @Test
        func NoEvaluationResponse() async {
            let flagDetails: FlagEvaluationDetails<Bool> = client.getDetails(
                key: "bool-key", defaultValue: false)
            
            #expect(false == flagDetails.value)
            #expect(ErrorCode.general == flagDetails.errorCode)
            #expect("Evaluation Response could not be retrieved" == flagDetails.errorMessage)
        }
    }
    
    @Suite(.serialized)
    struct ApiClientThrowsError {
        static let configuration = HyphenConfiguration(using: "project-public-key",
                                                       application: "hyphen-example-app",
                                                       environment: "development",
                                                       enableToggleUsage: false)
        
        let provider: HyphenProvider
        let client: Client
        
        internal init() async {
            let mockClient = MockApiClient()
            mockClient.error = OpenFeatureError.providerNotReadyError
            
            self.provider = HyphenProvider(using: Self.configuration, apiClient: mockClient)
            let context = MutableContext(targetingKey: UUID().uuidString)
            await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
            
            self.client = OpenFeatureAPI.shared.getClient()
        }
        
        @Test
        func getDetailsThrowsReturnsDefault() async {
            let flagDetails: FlagEvaluationDetails<Bool> = client.getDetails(
                key: "bool-key", defaultValue: false)
            
            #expect(false == flagDetails.value)
            #expect(ErrorCode.general == flagDetails.errorCode)
            #expect("Evaluation Response could not be retrieved" == flagDetails.errorMessage)
        }
    }
}
