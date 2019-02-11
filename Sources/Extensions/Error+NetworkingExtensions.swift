import Foundation
import Alamofire

/// Extension for network Error classification
public extension Error {

    /// Returns: true if error is connection error
    var isConnectionError: Bool {
        guard let urlError = self as? URLError else {
            return false
        }

        return urlError.code == .notConnectedToInternet || urlError.code == .timedOut
    }

    /// Returns: true if server json response is not valid
    var isResponseSerializationError: Bool {
        return (self as? AFError)?.isResponseSerializationError ?? false
    }
}
