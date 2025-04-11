import Foundation

struct EvaluationResponse: Codable, Sendable {
    internal init(id: String,
                  targetingKey: String,
                  toggles: [String : Evaluation]) {
        self.id = id
        self.targetingKey = targetingKey
        self.toggles = toggles
    }
    
    let id: String
    let targetingKey: String
    let toggles: [String: Evaluation]
}

struct Evaluation: Codable, Sendable {
    let key: String
    let value: CodableValue
    let type: String
    let reason: String?
    let errorMessage: String? 
}
