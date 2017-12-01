//
//  Copyright (c) 2017 Touch Instinct
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the Software), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Alamofire
import LeadKit
import RxSwift

/// Default implementation of network service, which trust any server and use default timeout interval
open class DefaultNetworkService: NetworkService {

    open class var retryLimit: UInt {
        return 3
    }

    private let disposeBag = DisposeBag()

    /// Override to set base server url
    open class var baseUrl: String {
        fatalError("You should override this var: baseUrl")
    }

    /// Override to change timeout interval default value
    open class var defaultTimeoutInterval: TimeInterval {
        return 20.0
    }

    /// The default acceptable range 200…299
    open var acceptableStatusCodes: [Int] {
        return Alamofire.SessionManager.defaultAcceptableStatusCodes
    }

    public init(sessionManager: SessionManager) {
        super.init(sessionManager: sessionManager, acceptableStatusCodes: acceptableStatusCodes)

        // Fatal error: `drive*` family of methods can be only called from `MainThread`
        DispatchQueue.main.async {
            self.activityIndicatorBinding()?.disposed(by: self.disposeBag)
        }
    }

    // MARK: - Default Values

    /// Override to change server trust policies
    open class var serverTrustPolicies: [String: ServerTrustPolicy] {
        return [
            baseUrl: .disableEvaluation
        ]
    }

    /// Override to change default urlSession configuration
    open class var configuration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = defaultTimeoutInterval

        return configuration
    }

    /// Override to configure alamofire session manager
    open class var sessionManager: SessionManager {
        let sessionManager = SessionManager(configuration: configuration,
                                            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        return sessionManager
    }

}
