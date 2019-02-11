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
import RxCocoa

public extension PassCodeHolderProtocol {

    var passCodeHolderCreate: PassCodeHolderCreate? {
        return self as? PassCodeHolderCreate
    }

    var passCodeHolderEnter: PassCodeHolderEnter? {
        return self as? PassCodeHolderEnter
    }

    var passCodeHolderChange: PassCodeHolderChange? {
        return self as? PassCodeHolderChange
    }
}

/// Holds information about pass codes during pass code creation process
public class PassCodeHolderCreate: PassCodeHolderProtocol {

    public let type: PassCodeOperationType = .create

    private var firstPassCode: String?
    private var secondPassCode: String?

    public var enterStep: PassCodeControllerState {
        if firstPassCode == nil {
            return .enter
        } else {
            return .repeatEnter
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
        case .enter:
            firstPassCode = passCode

        case .repeatEnter:
            secondPassCode = passCode

        default:
            break
        }
    }

    public func validate() -> PassCodeValidationResult {
        if let passCode = passCode {
            return .valid(passCode)
        } else {
            return .invalid(.codesNotMatch)
        }
    }

    public func reset() {
        firstPassCode = nil
        secondPassCode = nil
    }
}

/// Holds information about pass code during pass code entering process
public class PassCodeHolderEnter: PassCodeHolderProtocol {

    public let type: PassCodeOperationType = .enter
    public let enterStep: PassCodeControllerState = .enter

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
            return .invalid(nil)
        }
    }

    public func reset() {
        passCode = nil
    }
}

/// Holds information about pass codes during pass code changing process
public class PassCodeHolderChange: PassCodeHolderProtocol {

    public let type: PassCodeOperationType = .change

    private var oldPassCode: String?
    private var newFirstPassCode: String?
    private var newSecondPassCode: String?

    public var enterStep: PassCodeControllerState {
        guard oldPassCode != nil else {
            return .oldEnter
        }

        if newFirstPassCode == nil {
            return .newEnter
        } else {
            return .repeatEnter
        }
    }

    public var shouldValidate: Bool {
        if enterStep == .newEnter {
            return oldPassCode != nil
        } else {
            return newFirstPassCode != nil && newSecondPassCode != nil
        }
    }

    public var passCode: String? {
        switch (oldPassCode, newFirstPassCode, newSecondPassCode) {
        case (let oldPassCode?, nil, nil):
            return oldPassCode

        case (_, _?, nil):
            return nil

        case let (_, newFirstPassCode?, newSecondPassCode?) where newFirstPassCode == newSecondPassCode:
            return newFirstPassCode

        default:
            return nil
        }
    }

    public func add(passCode: String) {
        if oldPassCode == nil {
            oldPassCode = passCode
        } else if newFirstPassCode == nil {
            newFirstPassCode = passCode
        } else if newSecondPassCode == nil {
            newSecondPassCode = passCode
        }
    }

    public func validate() -> PassCodeValidationResult {
        if let passCode = passCode {
            return .valid(passCode)
        } else {
            return .invalid(enterStep == .newEnter ? nil : .codesNotMatch)
        }
    }

    public func reset() {
        if enterStep == .newEnter {
            oldPassCode = nil
        } else {
            newFirstPassCode = nil
            newSecondPassCode = nil
        }
    }
}
