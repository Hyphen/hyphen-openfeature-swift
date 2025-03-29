import Testing
import Foundation
import OpenFeature
@testable import Toggle

struct UserContextTests {
    @Test
    func testFromStructure_withAllFields_shouldParseCorrectly() async throws {
        let structure: [String: Value] = [
            "Email": .string("test@example.com"),
            "Name": .string("Jane Doe"),
            "CustomAttributes": .structure([
                "age": .integer(30),
                "isActive": .boolean(true),
                "tags": .list([
                    .string("swift"),
                    .string("ios")
                ])
            ])
        ]
        
        let userContext = try #require(UserContext.from(structure: structure))
        #expect("test@example.com" == userContext.email)
        #expect("Jane Doe" == userContext.name)
        
        #expect(3 == userContext.customAttributes.count)
        #expect(30 == userContext.customAttributes["age"]?.int)
        #expect(true == userContext.customAttributes["isActive"]?.anyValue as? Bool)
        #expect(["swift", "ios"] == userContext.customAttributes["tags"]?.anyValue as? [AnyHashable])
    }
    
    @Test
    func testFromStructure_withMissingFields_shouldHandleGracefully() throws {
        let structure: [String: Value] = [:]

        let userContext = try #require(UserContext.from(structure: structure))

        #expect(nil == userContext.email)
        #expect(nil == userContext.name)
        #expect(true == userContext.customAttributes.isEmpty)
    }
    
    @Test
    func testFromStructure_withOnlyCustomAttributes_shouldParseCorrectly() throws {
        let structure: [String: Value] = [
            "CustomAttributes": .structure([
                "language": .string("en"),
                "level": .string("advanced")
            ])
        ]
        
        let userContext = try #require(UserContext.from(structure: structure))
        #expect(nil == userContext.email)
        #expect(nil == userContext.name)
        
        #expect(2 == userContext.customAttributes.count)
        #expect("en" == userContext.customAttributes["language"]?.string)
        #expect("advanced" == userContext.customAttributes["level"]?.string)
    }
    
    @Test
    func testFromStructure_withNilStructure_shouldReturnNil() {
        #expect(nil == UserContext.from(structure: nil))
    }
    
    @Test
    func testFromStructure_withEmptyCustomAttributes_shouldReturnNilForCustomAttributes() throws {
        let structure: [String: Value] = [
            "Email": .string("jane@example.com"),
            "CustomAttributes": .structure([:])
        ]

        let userContext = try #require(UserContext.from(structure: structure))
        #expect("jane@example.com" == userContext.email)
        
        #expect(true == userContext.customAttributes.isEmpty)
    }
}
