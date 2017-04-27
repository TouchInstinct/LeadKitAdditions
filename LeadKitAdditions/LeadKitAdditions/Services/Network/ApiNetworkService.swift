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

import LeadKit
import Alamofire
import ObjectMapper
import RxSwift

open class ApiNetworkService: DefaultNetworkService {

    open func request<T: ImmutableMappable>(with parameters: ApiRequestParameters) -> Observable<T> {
        let apiResponseRequest = rxRequest(with: parameters) as Observable<(response: HTTPURLResponse, model: ApiResponse)>

        return apiResponseRequest
            .handleConnectionErrors()
            .map {
                if $0.model.errorCode == 0 {
                    return try T(JSON: try cast($0.model.result) as [String: Any])
                } else {
                    throw ApiError(apiResponse: $0.model)
                }
            }
    }

    open func requestForResult(with parameters: ApiRequestParameters) -> Observable<Bool> {
        let apiResponseRequest = rxRequest(with: parameters) as Observable<(response: HTTPURLResponse, model: ApiResponse)>

        return apiResponseRequest
            .handleConnectionErrors()
            .map {
                if $0.model.errorCode == 0,
                    let result = $0.model.result as? Bool {
                    return result
                } else {
                    throw ApiError(apiResponse: $0.model)
                }
            }
    }

}
