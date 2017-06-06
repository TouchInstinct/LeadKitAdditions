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
import LeadKit

/// Represents service that store basic user information
open class BaseUserService {

    public init() {
        // Can be overrided
    }

    /// Returns user login
    open var userLogin: String {
        guard let defaultsLogin = UserDefaults.standard.userLogin else {
            assertionFailure("userLogin is nil. Use isLoggedIn before read userLogin")
            return ""
        }

        return defaultsLogin
    }

    /// Returns session id
    open var sessionId: String {
        guard let defaultsSessionId = UserDefaults.standard.sessionId else {
            assertionFailure("sessionId is nil. Use isLoggedIn before read sessionId")
            return ""
        }
        return defaultsSessionId
    }

    /// Indicates if user is logged in
    open var isLoggedIn: Bool {
        return UserDefaults.standard.sessionId != nil
    }

    /// Reset user information
    open class func clearData() {
        UserDefaults.standard.sessionId = nil
        UserDefaults.standard.userLogin = nil
    }

}
