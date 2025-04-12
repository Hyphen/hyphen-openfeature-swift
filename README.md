# Hyphen Toggle OpenFeature Provider for Swift

The **Hyphen Toggle OpenFeature Provider** is an OpenFeature provider implementation for the Hyphen Toggle platform using Swift. It enables feature flag evaluation using the OpenFeature standard.

![Build Status](https://github.com/hyphen/hyphen-openfeature-swift/actions/workflows/swift.yml/badge.svg) ![MIT License](https://img.shields.io/badge/License-MIT-green.svg) ![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/hyphen/hyphen-openfeature-swift?label=Version) ![Platforms: iOS | macOS](https://img.shields.io/badge/platforms-iOS%20|%20macOS-blue?logo=apple)
![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-orange?logo=swift)

---

## Table of Contents

1. [Installation](#installation)
2. [Setup and Initialization](#setup-and-initialization)
3. [Usage](#usage)
4. [Configuration](#configuration)
5. [License](#license)

---

## Installation

Using the [Swift Package Manager](https://swift.org/package-manager/): either through Xcode > File > Swift Packages > Add Package Dependency... and enter this repo URL (including the `.git` extension), , then choose `Toggle` target. Or add the line  `.package(url: "https://github.com/hyphen/hyphen-openfeature-swift", from: "0.2.0")` in the `dependencies` section of your `Package.swift` file.

## Setup and Initialization
To integrate the Hyphen Toggle provider into your application, follow these steps:

1. Configure the provider with your `publicKey` and provider options.
2. Register the provider with OpenFeature.

```swift
import Toggle
import OpenFeature

let configuration = HyphenConfiguration(using: "project-public-key",
                                                application: "hyphen-example-app",
                                                environment: "development")

let provider = HyphenProvider(using: Self.configuration)
await OpenFeatureAPI.shared.setProviderAndWait(provider: provider)
```

3. Configure the context needed for feature targeting evaluations, incorporating user or application context.
```swift

let provider = HyphenProvider(using: configuration)
let context = hyphenEvaluationContext(
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

await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
```

### Usage
### Evaluation Context Example

```swift
let client = OpenFeatureAPI.shared.getClient()
let flagDetails: FlagEvaluationDetails<Bool> = client.getDetails(key: ToggleKey.bool, defaultValue: false)
```

## Configuration
### Options

| Option              | Type      | Required | Description                                     |
|--------------------|-----------|----------|-------------------------------------------------|
| `Public Key`       | string    | Yes      | The public key from the Hyphen project          |
| `Application`      | string    | Yes      | The application id or alternate id              |
| `Environment`      | string    | Yes      | The environment identifier for the Hyphen project (project environment ID or alternateId). |
| `HorizonUrls`      | string[]  | No       | Hyphen Horizon URLs for fetching flags         |
| `EnableToggleUsage`| bool?     | No       | Enable/disable telemetry (default: True).      |

### Network Options 

| Property              | Type       | Default | Description                                                    |
|----------------------|------------|---------|----------------------------------------------------------------|
| `useCellularAccess`  | bool       | true    | Use Cellular Access to retrieve toggle evaluations             |
| `timeout`            | number     | 10      | Timeout in seconds for retrieving the toggle evaluations       |
| `maxRetries`         | number     | 3       | The number of times we will retry the retrieval of toggles     |
| `retryDelay`         | number     | 3       | The amount of time we will wait between requests               |
| `cacheExpiration`    | number     | 900     | ttl for the evaluation response                                |

### Context
Provide a `HyphenEvaluationContext` to pass contextual data for feature evaluation.

| Field               | Type                           | Required | Description                    |
|-------------------|--------------------------------|----------|--------------------------------|
| `TargetingKey`    | string                         | Yes      | Caching evaluation key        |
| `CustomAttributes`| Dictionary<string, object>     | No       | Additional context information |
| `User`            | UserContext                    | No       | User-specific information     |
| `User.Id`         | string                         | No       | Unique identifier of the user |
| `User.Email`      | string                         | No       | Email address of the user |
| `User.Name`       | string                         | No       | Name of the user |
| `User.CustomAttributes` | Dictionary<string, object>  | No       | Custom attributes specific to the user |


## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for full details.

## Dependencies

### OpenFeature iOS SDK

<!-- x-hide-in-docs-start -->
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/open-feature/community/0e23508c163a6a1ac8c0ced3e4bd78faafe627c7/assets/logo/horizontal/white/openfeature-horizontal-white.svg" />
    <img align="center" alt="OpenFeature Logo" src="https://raw.githubusercontent.com/open-feature/community/0e23508c163a6a1ac8c0ced3e4bd78faafe627c7/assets/logo/horizontal/black/openfeature-horizontal-black.svg" />
  </picture>
</p>

- OpenFeature is an open specification that provides a vendor-agnostic, community-driven API for feature flagging that works with your favorite feature flag management tool or in-house solution. 
- License: [APACHE 2.0](https://github.com/open-feature/swift-sdk/blob/main/LICENSE)
- Repo: https://github.com/open-feature/swift-sdk
