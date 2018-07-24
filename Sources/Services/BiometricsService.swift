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

import LocalAuthentication

public typealias BiometricsAuthHandler = (Bool, Error?) -> Void

/// Service that provide access to authentication via biometric
public final class BiometricsService {

    private lazy var laContext = LAContext()

    /// Returns current domain state
    public var evaluatedPolicyDomainState: Data? {
        // We need to call canEvaluatePolicy function for evaluatedPolicyDomainState to be updated
        _ = canAuthenticateWithBiometrics
        return laContext.evaluatedPolicyDomainState
    }

    /// Indicates is it possible to authenticate on this device via touch id
    public var canAuthenticateWithBiometrics: Bool {
        return laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    /**
     Initiates system biometrics authentication process

      - parameters:
        - description: prompt on the system alert
        - fallback: alternative action button title on system alert
        - cancel: cancel button title on the system alert
        - authHandler: callback, with parameter, indicates if user authenticate successfuly
     */
    public func authenticateWithBiometrics(with description: String,
                                           fallback fallbackTitle: String?,
                                           cancel cancelTitle: String?,
                                           authHandler: @escaping BiometricsAuthHandler) {
        if #available(iOS 10.0, *) {
            laContext.localizedCancelTitle = cancelTitle
        }
        laContext.localizedFallbackTitle = fallbackTitle

        laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description) { success, error in
            authHandler(success, error)
        }
    }

    public init() {}

}
