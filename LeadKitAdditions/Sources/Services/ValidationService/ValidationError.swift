import SwiftValidator

public struct ValidationError: Error {

    public let failedRule: Rule
    public let errorMessage: String?
    public let errorHint: String?

    public init(failedRule: Rule, errorMessage: String?, errorHint: String? = nil) {
        self.failedRule = failedRule
        self.errorMessage = errorMessage
        self.errorHint = errorHint
    }

}
