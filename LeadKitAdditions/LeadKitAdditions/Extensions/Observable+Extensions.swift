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

import RxSwift
import Alamofire
import CocoaLumberjack

public typealias VoidBlock = () -> Void

public extension Observable {

    public func handleConnectionErrors() -> Observable<Observable.E> {
        return observeOn(CurrentThreadScheduler.instance)

            // handle no internet connection
            .do(onError: { error in
                if let urlError = error as? URLError,
                    urlError.code == .notConnectedToInternet ||
                        urlError.code == .timedOut {
                    DDLogError("Error: No Connection")
                    throw ConnectionError.noConnection
                }
            })

            // handle unacceptable http status code like "500 Internal Server Error" and others
            .do(onError: { error in
                if let afError = error as? AFError,
                    case let .responseValidationFailed(reason: reason) = afError,
                    case let .unacceptableStatusCode(code: statusCode) = reason {
                    DDLogError("Error: Unacceptable HTTP Status Code - \(statusCode)")
                    throw ConnectionError.noConnection
                }
            })
    }

    public func retryWithinErrors(_ errorTypes: [Error.Type] = [ConnectionError.self],
                                  retryLimit: Int = DefaultNetworkService.retryLimit)
        -> Observable<Observable.E> {

            return observeOn(CurrentThreadScheduler.instance)
                .retryWhen { errors -> Observable<Observable.E> in
                    return errors.flatMapWithIndex { e, a -> Observable<Observable.E> in
                        let canRetry = errorTypes.contains { type(of: e) == $0 }

                        return (canRetry && a < retryLimit - 1) ? self : .error(e)
                    }
            }
    }

}
