import Foundation

public struct HyphenConfiguration {
    /// The key to use to communicate with the Hyphen Service
    public var publicKey: PublicKey
    
    /// The application name or ID for the current evaluation.
    public var application: String

    /// The environment identifier for the Hyphen project.
    public var environment: String
    
    /// Flag to enable toggle usage (default is `true`)
    public var enableToggleUsage: Bool
    
    /// Configure the behavior of the network requests
    public var networkOptions: NetworkOptions

    /// Computed evaluation URLs (fallbacks to default if custom is nil)
    public var evaluationUrls: [URL] {
        urls.evaluationUrls
    }

    /// Computed telemetry URLs (fallbacks to default if custom is nil)
    public var telemetryUrls: [URL] {
        urls.telemetryUrls
    }

    private var urls: HyphenUrls

    public init(
        using publicKey: String,
        application: String,
        environment: String,
        customUrls: [URL] = [],
        enableToggleUsage: Bool = true,
        networkOptions: NetworkOptions = NetworkOptions()
    ) {
        self.publicKey = PublicKey(publicKey)
        self.application = application
        self.environment = environment
        self.urls = HyphenUrls(publicKey: publicKey, customUrls: customUrls)
        self.enableToggleUsage = enableToggleUsage
        self.networkOptions = networkOptions
    }
}


