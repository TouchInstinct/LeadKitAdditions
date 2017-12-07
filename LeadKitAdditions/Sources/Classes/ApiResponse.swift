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

import ObjectMapper

/// Class describes typical response from server, which designed by TouchInstinct
public class ApiResponse: ApiResponseProtocol, ImmutableMappable {

    /// nil in case of error, result of request otherwise
    public let result: Any?
    /// In case of error contains error code, 0 (zero) otherwise
    public let errorCode: Int
    /// nil in case of success, error description otherwise
    public let errorMessage: String?

    public required init(map: Map) throws {
        result = try? map.value("result")
        errorCode = try map.value("errorCode")
        errorMessage = try? map.value("errorMessage")
    }

}

/// Describes error, which received from server designed by TouchInstinct
public protocol ApiResponseProtocol: ImmutableMappable {

    /// Error code
    var errorCode: Int { get }
    /// Error description
    var errorMessage: String? { get }

}
