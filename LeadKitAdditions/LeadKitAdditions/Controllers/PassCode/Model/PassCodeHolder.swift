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
import RxCocoa

extension PassCodeHolderProtocol {

    public var passCodeHolderCreate: PassCodeHolderCreate? {
        return self as? PassCodeHolderCreate
    }

    public var passCodeHolderEnter: PassCodeHolderEnter? {
        return self as? PassCodeHolderEnter
    }

}

public class PassCodeHolderCreate: PassCodeHolderProtocol {

    public let type: PassCodeControllerType = .create

    private var firstPassCode: String?
    private var secondPassCode: String?

    public var enterStep: PassCodeEnterStep {
        if firstPassCode == nil {
            return .first
        } else {
            return .second
        }
    }

    public var shouldValidate: Bool {
        return firstPassCode != nil && secondPassCode != nil
    }

    public var passCode: String? {
        guard let firstPassCode = firstPassCode, let secondPassCode = secondPassCode, firstPassCode == secondPassCode else {
            return nil
        }

        return firstPassCode
    }

    public func add(passCode: String) {
        switch enterStep {
        case .first:
            firstPassCode = passCode
        case .second:
            secondPassCode = passCode
        }
    }

    public func validate() -> PassCodeValidationResult {
        if let passCode = passCode {
            return .valid(passCode)
        } else {
            return .inValid(.codesNotMatch)
        }
    }

    public func reset() {
        firstPassCode  = nil
        secondPassCode = nil
    }

}

public class PassCodeHolderEnter: PassCodeHolderProtocol {

    public let type: PassCodeControllerType = .enter
    public let enterStep: PassCodeEnterStep = .first

    public var shouldValidate: Bool {
        return passCode != nil
    }

    public var passCode: String?

    public func add(passCode: String) {
        self.passCode = passCode
    }

    public func validate() -> PassCodeValidationResult {
        if let passCode = passCode {
            return .valid(passCode)
        } else {
            return .inValid(nil)
        }
    }

    public func reset() {
        passCode = nil
    }

}
