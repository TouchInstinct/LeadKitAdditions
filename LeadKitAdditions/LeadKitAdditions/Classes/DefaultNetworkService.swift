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

import Foundation
import Alamofire
import LeadKit
import ObjectMapper
import RxSwift
import RxCocoa
import RxAlamofire

fileprivate let defaultTimeoutInterval = 20.0

open class DefaultNetworkService: NetworkService {

    static let sharedInstance = DefaultNetworkService()

    static let retryLimit = 3

    open class func baseUrl() -> String {
        fatalError("base url should be overrided")
    }

    private override init(sessionManager: Alamofire.SessionManager) {
        super.init(sessionManager: sessionManager)

        bindActivityIndicator()
    }

    public convenience init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = defaultTimeoutInterval

        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            DefaultNetworkService.baseUrl(): .disableEvaluation
        ]

        let sessionManager = SessionManager(configuration: configuration,
                                            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))

        self.init(sessionManager: sessionManager)
    }

    // MARK: - Internal methods

//    func request<T: ImmutableMappable>(with parameters: ApiRequestParameters) -> Observable<T> {
//        let apiResponseRequest = rxRequest(with: parameters) as Observable<(response: HTTPURLResponse, model: ApiResponse)>
//
//        return apiResponseRequest
//            .handleConnectionErrors()
//            .map {
//                if $0.model.errorCode == 0 {
//                    return try T(JSON: try cast($0.model.result) as [String: Any])
//                } else {
//                    throw ApiError(apiResponse: $0.model)
//                }
//            }
//            .handleGeneralApiErrors()
//    }
//
//    func requestForResult(with parameters: ApiRequestParameters) -> Observable<Bool> {
//        let apiResponseRequest = rxRequest(with: parameters) as Observable<(response: HTTPURLResponse, model: ApiResponse)>
//
//        return apiResponseRequest
//            .handleConnectionErrors()
//            .map {
//                if $0.model.errorCode == 0 {
//                    return true
//                } else {
//                    throw ApiError(apiResponse: $0.model)
//                }
//            }
//            .handleGeneralApiErrors()
//    }

}

extension ApiRequestParameters {

    init(url: String, parameters: [String: Any] = [:]) {

        self.init(url: DefaultNetworkService.baseUrl() + url,
                  method: .post,
                  parameters: parameters,
                  encoding: JSONEncoding.default,
                  headers: nil)
    }

}
