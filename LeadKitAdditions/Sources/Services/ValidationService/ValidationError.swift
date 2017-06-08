import SwiftValidator

struct ValidationError: Error {

    let failedRule: Rule
    let errorMessage: String?
    let errorHint: String?

    init(failedRule: Rule, errorMessage: String?, errorHint: String? = nil) {
        self.failedRule = failedRule
        self.errorMessage = errorMessage
        self.errorHint = errorHint
    }

}
