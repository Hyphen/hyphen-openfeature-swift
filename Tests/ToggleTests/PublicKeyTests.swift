import Testing
import Foundation
@testable import Toggle

struct PublicKeyTests {
    
    @Test
    func testEmptyStringReturnsNil() {
        let publicKey = PublicKey("")
        #expect(nil == publicKey.orgId)
    }

    @Test
    func testMalformedBase64ReturnsNil() {
        let malformedKey = "public_!!!invalidbase64"
        
        let publicKey = PublicKey(malformedKey)
        #expect(nil == publicKey.orgId)
    }
    
    @Test
    func testOrgIdWithInvalidCharactersReturnsNil() {
        let encoded = Data("org with spaces:stuff".utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let publicKey = PublicKey(key)
        #expect(nil == publicKey.orgId)
    }
    
    @Test
    func testDecodedStringWithoutColonReturnsNil() {
        let encoded = Data("missingcolonvalue".utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let publicKey = PublicKey(key)
        #expect(nil == publicKey.orgId)
    }
    
    @Test
    func testInvalidPrefixIsStillParsed() {
        let validRaw = "orgABC:more-stuff"
        let encoded = Data(validRaw.utf8).base64EncodedString()
        let key = encoded

        let publicKey = PublicKey(key)
        #expect("orgABC" == publicKey.orgId)
    }
    
    @Test
    func testValidPublicKeyReturnsOrgId() {
        let validRaw = "org-123:extra-data"
        let encoded = Data(validRaw.utf8).base64EncodedString()
        let key = "public_\(encoded)"

        let publicKey = PublicKey(key)
        #expect("org-123" == publicKey.orgId)
    }
}
