import Foundation
import OpenFeature

public protocol ApiClientProtocol {
    func request<T: Codable, R: Decodable>(
        config: HyphenConfiguration,
        endpoint: Endpoint,
        body: T
    ) async throws -> R?
}
