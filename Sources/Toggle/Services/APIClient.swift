import Foundation

public final class ApiClient: ApiClientProtocol {
    public init() { }
    
    private func session(options: NetworkOptions) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = options.timeout
        configuration.timeoutIntervalForResource = options.timeout
        configuration.allowsCellularAccess = options.useCellularAccess
        configuration.allowsExpensiveNetworkAccess = options.useCellularAccess
        configuration.allowsConstrainedNetworkAccess = options.useCellularAccess
        
        return URLSession(configuration: configuration)
    }
    
    public func request<T: Codable, R: Decodable>(
        config: HyphenConfiguration,
        endpoint: Endpoint,
        body: T
    ) async throws -> R? {
        let urls: [URL]
        switch endpoint {
        case .evaluate:
            urls = config.evaluationUrls
        case .telemetry:
            urls = config.telemetryUrls
        }
        
        return try await request(
            from: urls,
            publicKey: config.publicKey,
            body: body,
            options: config.networkOptions
        )
    }
    
    private func request<T: Codable, R: Decodable>(
        from baseURLs: [URL],
        publicKey: PublicKey,
        body: T? = nil,
        httpMethod: HttpMethod = .post,
        options: NetworkOptions
    ) async throws -> R? {
        var lastError: Error?
        let header: [String: String] = ["x-api-key": publicKey.key]
        
        for attempt in 1 ... options.maxRetries {
            for baseURL in baseURLs {
                do {
                    LoggerManager.shared.debug("Attempting request to \(baseURL), attempt \(attempt)")
                    return try await requestOnce(
                        from: baseURL,
                        httpMethod: httpMethod,
                        header: header,
                        body: body,
                        options: options
                    )
                } catch {
                    LoggerManager.shared.debug("Request to \(baseURL) failed: \(error)")
                    lastError = error
                    if !shouldRetry(error: error) {
                        throw error
                    }
                }
            }
            
            let delay = pow(options.retryDelay, Double(attempt))
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        throw lastError ?? NetworkError.unknownServerError(statusCode: -1)
    }
    
    private func requestOnce<T: Codable, R: Decodable>(
        from baseURL: URL,
        httpMethod: HttpMethod,
        header: [String: String],
        body: T?,
        options: NetworkOptions
    ) async throws -> R? {
        guard let url = buildURL(baseURL: baseURL) else {
            throw NetworkError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body, [.post, .put, .patch].contains(httpMethod) {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let session = session(options: options)
        let (data, response) = try await session.data(for: request)
        try validate(response: response)
        
        if data.isEmpty {
            return nil
        }
        
        let decodedValue = try JSONDecoder().decode(R.self, from: data)
        return decodedValue
    }

    
    private func shouldRetry(error: Error) -> Bool {
        switch error {
        case NetworkError.internalServerError,
            NetworkError.unknownServerError,
            URLError.timedOut,
            URLError.networkConnectionLost,
            URLError.cannotConnectToHost:
            return true
        default:
            return false
        }
    }
    
    private func buildURL(baseURL: URL) -> URL? {
        URLComponents(url: baseURL, resolvingAgainstBaseURL: false)?.url
    }
    
    private func validate(response: URLResponse?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 404:
            throw NetworkError.notFound
        case 500:
            throw NetworkError.internalServerError
        default:
            throw NetworkError.unknownServerError(statusCode: httpResponse.statusCode)
        }
    }
}


