import Foundation
@testable import Toggle

extension UserContext {
    static let mock: UserContext = {
        return UserContext.make(email: "matthew@silewski.com",
                                name: "Matthew Osborn",
                                customAttributes: ["role": "admin"])

    }()
}
