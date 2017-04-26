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

import KeychainAccess
import CocoaLumberjack
import CommonCrypto

open class BasePassCodeService {

    open class var keychainService: String {
        return Bundle.main.bundleIdentifier ?? ""
    }

    public init() {
        let isInitialLoad = UserDefaults.standard.bool(forKey: Keys.isInitialLoad)
        if isInitialLoad {
            UserDefaults.standard.set(false, forKey: Keys.isInitialLoad)
            reset()
        }
    }

    // MARK: - Private stuff

    fileprivate lazy var keychain: Keychain = {
        return Keychain(service: keychainService)
            .synchronizable(false)
    }()

    fileprivate var passCodeHash: String? {
        return keychain[Keys.passCodeHash]
    }

    fileprivate enum Keys {
        static let passCodeHash     = "passCodeHash"
        static let isTouchIdEnabled = "isTouchIdEnabled"
        static let isInitialLoad    = "isInitialLoad"
    }

    fileprivate enum Values {
        static let touchIdEnabled = "touchIdEnabled"
    }

}

extension BasePassCodeService {

    public var isPassCodeSaved: Bool {
        return keychain[Keys.passCodeHash] != nil
    }

    public var isTouchIdEnabled: Bool {
        get {
            return keychain[Keys.isTouchIdEnabled] == Values.touchIdEnabled
        }
        set {
            keychain[Keys.isTouchIdEnabled] = newValue ? Values.touchIdEnabled : nil
        }
    }

    public func save(passCode: String?) {
        if let passCode = passCode {
            keychain[Keys.passCodeHash] = sha256(passCode)
        } else {
            keychain[Keys.passCodeHash] = nil
        }
    }

    public func check(passCode: String) -> Bool {
        return sha256(passCode) == passCodeHash
    }

    public func reset() {
        save(passCode: nil)
        isTouchIdEnabled = false
    }

}

private extension BasePassCodeService {

    func sha256(_ str: String) -> String? {
        guard let data = str.data(using: String.Encoding.utf8), let shaData = sha256(data) else {
            return nil
        }

        let rc = shaData.base64EncodedString(options: [])
        return rc
    }

    func sha256(_ data: Data) -> Data? {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else {
            return nil
        }

        CC_SHA256((data as NSData).bytes, CC_LONG(data.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
        return res as Data
    }

}
