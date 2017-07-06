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
import RxSwift
import RxCocoa

/// Describes types of authentication
public enum PassCodeAuthType {
    case passCode(String)
    case touchId
}

/// Base view model for passCodeViewController
open class BasePassCodeViewModel: BaseViewModel {

    public let controllerType: PassCodeControllerType

    public let disposeBag = DisposeBag()

    /// TouchId service, which can answer if user is authorized by finger
    public let touchIdService: TouchIDService?
    /// Contains configuration for pass code operations
    public let passCodeConfiguration: PassCodeConfiguration

    fileprivate let validationResultHolder = Variable<PassCodeValidationResult?>(nil)
    var validationResult: Driver<PassCodeValidationResult?> {
        return validationResultHolder.asDriver()
    }

    fileprivate let passCodeControllerStateHolder = Variable<PassCodeControllerState>(.enter)
    public var passCodeControllerState: Driver<PassCodeControllerState> {
        return passCodeControllerStateHolder.asDriver()
    }

    public let passCodeText = Variable<String?>(nil)

    fileprivate var attemptsNumber = 0

    fileprivate lazy var passCodeHolder: PassCodeHolderProtocol = {
        return PassCodeHolderBuilder.build(with: self.controllerType)
    }()

    public init(controllerType: PassCodeControllerType,
                passCodeConfiguration: PassCodeConfiguration,
                touchIdService: TouchIDService? = nil) {

        self.controllerType = controllerType
        self.passCodeConfiguration = passCodeConfiguration
        self.touchIdService = touchIdService

        bindViewModel()
    }

    private func bindViewModel() {
        passCodeText.asDriver()
            .distinctUntilChanged { $0 == $1 }
            .drive(onNext: { [weak self] passCode in
                if let passCode = passCode,
                    passCode.characters.count == Int(self?.passCodeConfiguration.passCodeCharactersNumber ?? 0) {
                    self?.set(passCode: passCode)
                }
            })
            .addDisposableTo(disposeBag)

        validationResultHolder.asDriver()
            .drive(onNext: { [weak self] validationResult in
                guard let sSelf = self else {
                    return
                }

                if sSelf.passCodeHolder.type == .change {
                    if validationResult?.isValid ?? false,
                        sSelf.passCodeHolder.enterStep == .repeatEnter,
                        let passCode = validationResult?.passCode {

                        sSelf.authSucceed(.passCode(passCode))
                    } else {
                        sSelf.passCodeControllerStateHolder.value = sSelf.passCodeHolder.enterStep
                    }
                } else {
                    if validationResult?.isValid ?? false, let passCode = validationResult?.passCode {
                        sSelf.authSucceed(.passCode(passCode))
                    } else {
                        sSelf.passCodeControllerStateHolder.value = sSelf.passCodeHolder.enterStep
                    }
                }
            })
            .addDisposableTo(disposeBag)
    }

    public func reset() {
        passCodeText.value = nil
        validationResultHolder.value = nil
        passCodeControllerStateHolder.value = controllerType == .change ? .oldEnter : .enter
        attemptsNumber = 0
        passCodeHolder.reset()
    }

    // MARK: - HAVE TO OVERRIDE

    /// Override to check if entered pass code is equal to stored
    open func isEnteredPassCodeValid(_ passCode: String) -> Bool {
        assertionFailure("You should override this method: isEnteredPassCodeValid(_ passCode: String)")
        return false
    }

    /// Handler called after successful authentication
    open func authSucceed(_ type: PassCodeAuthType) {
        assertionFailure("You should override this method: authSucceed(_ type: PassCodeAuthType)")
    }

    // MARK: - Functions that can you can override to use TouchId

    /// Override to be able use touchId during authentication
    open var isTouchIdEnabled: Bool {
        return false
    }

    /// You should save user choice about authenticate by touchId
    open func activateTouchIdForUser() {
        assertionFailure("You should override this method: activateTouchIdForUser()")
    }

}

extension BasePassCodeViewModel {

    fileprivate func set(passCode: String) {
        passCodeHolder.add(passCode: passCode)
        validateIfNeeded()

        if shouldUpdateControllerState {
            passCodeControllerStateHolder.value = passCodeHolder.enterStep
        }
    }

    private var shouldUpdateControllerState: Bool {
        return !passCodeHolder.shouldValidate ||
            !(validationResultHolder.value?.isValid ?? true) ||
            validationResultHolder.value?.error == .tooManyAttempts
    }

    private func validateIfNeeded() {
        guard passCodeHolder.shouldValidate else {
            return
        }

        var validationResult = passCodeHolder.validate()

        if passCodeHolder.type == .enter || (passCodeHolder.type == .change && passCodeHolder.enterStep == .newEnter) {
            attemptsNumber += 1

            if let passCode = validationResult.passCode, !isEnteredPassCodeValid(passCode) {
                validationResult = .inValid(.wrongCode)
            }

            if (!validationResult.isValid && attemptsNumber == Int(passCodeConfiguration.maxAttemptsLoginNumber)) ||
                attemptsNumber > Int(passCodeConfiguration.maxAttemptsLoginNumber) {
                validationResult = .inValid(.tooManyAttempts)
            }
        }

        if !validationResult.isValid {
            passCodeHolder.reset()
        }

        validationResultHolder.value = validationResult
    }

}
