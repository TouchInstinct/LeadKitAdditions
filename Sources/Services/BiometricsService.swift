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

    /// If the user unlocks the device using biometrics within the specified time interval,
    /// then authentication for the receiver succeeds automatically, without prompting the user for biometrics.
    /// Works only after device unlock event, no other apps authentications counts.
    public var allowableReuseDuration: TimeInterval? = nil {
        didSet {
            guard let duration = allowableReuseDuration else {
                return
            }
            if #available(iOS 9.0, *) {
                laContext.touchIDAuthenticationAllowableReuseDuration = duration
            }
        }
    }

    /// Returns true if user can authenticate via Face ID
    public var isFaceIdSupported: Bool {
        if #available(iOS 11.0, *) {
            return canAuthenticateWithBiometrics && laContext.biometryType == .faceID
        }
        return false
    }

    /// Returns true if user can authenticate via Touch ID
    public var isTouchIdSupported: Bool {
        let canEvaluate = canAuthenticateWithBiometrics
        if #available(iOS 11.0, *) {
            return canEvaluate && laContext.biometryType == .touchID
        }
        return canEvaluate
    }

    /// Returns current domain state
    public var evaluatedPolicyDomainState: Data? {
        // We need to call canEvaluatePolicy function for evaluatedPolicyDomainState to be updated
        _ = canAuthenticateWithBiometrics
        return laContext.evaluatedPolicyDomainState
    }

    /// Indicates is it possible to authenticate on this device via any biometric.
    /// Returns false if not enrolled or lockedout.
    public var canAuthenticateWithBiometrics: Bool {
        return laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    /**
     Initiates system biometrics authentication process.
     Once evaluated, will return success until the context is deallocated or invalidated.

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

    /// This method allows invalidating the context manually while it is in scope.
    /// Invalidation terminates any existing policy evaluation and the respective call will
    /// fail with LAErrorAppCancel.
    public func invalidate() {
        laContext = LAContext()
    }

    public init() {}
}
