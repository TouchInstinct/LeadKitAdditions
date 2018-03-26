//
//  Copyright (c) 2018 Touch Instinct
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
import LeadKit

public typealias VoidBlock = () -> Void

public extension Observable {

    /// A closure that checks for "retryable" error
    typealias CanRetryClosure = (Error) -> Bool

    /// Allow to configure request to restart if error occured
    ///
    /// - Parameters:
    ///   - retryLimit: how many times request can restarts
    ///   - canRetryClosure: a closure that checks for "retryable" error
    /// - Returns: An observable sequence producing the elements of the given sequence repeatedly
    /// until it terminates successfully or is notified to error or complete.
    func retry(retryLimit: UInt = DefaultNetworkService.retryLimit,
               canRetryClosure: @escaping CanRetryClosure) -> Observable<Observable.E> {

            return observeOn(CurrentThreadScheduler.instance)
                .retryWhen { errorsObservable -> Observable<Observable.E> in
                    errorsObservable.enumerated().flatMap {
                        (canRetryClosure($1) && $0 < retryLimit - 1) ? self : .error($1)
                    }
                }
    }

    /**
     Add block that executes, when error, described by ApiErrorProtocol, occured during request
     
      - parameters:
        - apiErrorType: type of errors, received frim server
        - handler: block, that executes, when error occured
     */
    func handleApiError<T: ApiErrorProtocol>(_ apiErrorType: T,
                                             handler: @escaping () -> Void) -> Observable<Observable.E>
        where T.RawValue == Int {

        return observeOn(CurrentThreadScheduler.instance)
            .do(onError: { error in
                if error.isApiError(apiErrorType) {
                    handler()
                }
            })
    }

    /**
     Add ability to monitor request status
     
      - parameter isLoading: subject, request state bind to
     */
    func changeLoadingBehaviour(isLoading: PublishSubject<Bool>) -> Observable<Observable.E> {
        return observeOn(CurrentThreadScheduler.instance)
            .do(onNext: { _ in
                isLoading.onNext(false)
            }, onError: { _ in
                isLoading.onNext(false)
            }, onSubscribe: {
                isLoading.onNext(true)
            })
    }

}
