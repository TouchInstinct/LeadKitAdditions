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

import KeychainAccess
import CocoaLumberjack
import IDZSwiftCommonCrypto

private enum Keys {
    static let passCodeHash        = "passCodeHashKey"
    static let isBiometricsEnabled = "isBiometricsEnabledKey"
    static let isInitialLoad       = "isInitialLoadKey"
}

private enum Values {
    static let biometricsEnabled = "biometricsEnabled"
    static let initialLoad       = "initialLoad"
}

/// Represents base pass code service which encapsulates pass code storing
open class BasePassCodeService {

    /// Override to set specific keychain service name
    open class var keychainServiceString: String {
        return Bundle.main.bundleIdentifier ?? ""
    }

    public init() {
        let initialLoadValue = UserDefaults.standard.value(forKey: Keys.isInitialLoad)
        if initialLoadValue == nil {
            UserDefaults.standard.set(Values.initialLoad, forKey: Keys.isInitialLoad)
            reset()
        }
    }

    // MARK: - Private stuff

    private lazy var keychain = Keychain(service: BasePassCodeService.keychainServiceString).synchronizable(false)

    private var passCodeHash: String? {
        return keychain[Keys.passCodeHash]
    }



}

public extension BasePassCodeService {

    /// Indicates is pass code already saved on this device
    var isPassCodeSaved: Bool {
        return keychain[Keys.passCodeHash] != nil
    }

    /// Possibility to authenticate via biometrics. TouchID or FaceID
    var isBiometricsAuthorizationEnabled: Bool {
        get {
            return keychain[Keys.isBiometricsEnabled] == Values.biometricsEnabled
        }
        set {
            keychain[Keys.isBiometricsEnabled] = newValue ? Values.biometricsEnabled : nil
        }
    }

    /// Saves new pass code
    func save(passCode: String?) {
        if let passCode = passCode {
            keychain[Keys.passCodeHash] = sha256(passCode)
        } else {
            keychain[Keys.passCodeHash] = nil
        }
    }

    /// Check if pass code is correct
    func check(passCode: String) -> Bool {
        return sha256(passCode) == passCodeHash
    }

    /// Reset pass code settings
    func reset() {
        save(passCode: nil)
        isBiometricsAuthorizationEnabled = false
    }

}

private extension BasePassCodeService {

    func sha256(_ str: String) -> String? {
        guard let digests = Digest(algorithm: .sha256).update(string: str)?.final() else {
            return nil
        }
        return hexString(fromArray: digests)
    }

}
