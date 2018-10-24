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

    public let operationType: PassCodeOperationType

    public let disposeBag = DisposeBag()

    /// Service that can answer if user is authorized by biometrics
    public let biometricsService = BiometricsService()

    /// Contains configuration for pass code operations
    public let passCodeConfiguration: PassCodeConfiguration

    private let validationResultHolder = Variable<PassCodeValidationResult?>(nil)
    public var validationResultDriver: Driver<PassCodeValidationResult?> {
        return validationResultHolder.asDriver()
    }

    private let passCodeControllerStateVariable = Variable<PassCodeControllerState>(.enter)
    public var passCodeControllerStateDriver: Driver<PassCodeControllerState> {
        return passCodeControllerStateVariable.asDriver()
    }

    private let passCodeText = Variable<String?>(nil)

    private var attemptsNumber = 0

    private lazy var passCodeHolder: PassCodeHolderProtocol = PassCodeHolderBuilder.build(with: self.operationType)

    public init(operationType: PassCodeOperationType, passCodeConfiguration: PassCodeConfiguration) {
        self.operationType = operationType
        self.passCodeConfiguration = passCodeConfiguration

        bindViewModel()
    }

    private func bindViewModel() {
        passCodeText.asDriver()
            .distinctUntilChanged { $0 == $1 }
            .drive(onNext: { [weak self] passCode in
                if let passCode = passCode,
                    passCode.count == Int(self?.passCodeConfiguration.passCodeLength ?? 0) {
                    self?.set(passCode: passCode)
                }
            })
            .disposed(by: disposeBag)

        validationResultHolder.asObservable()
            .bind(to: validationResultBinder)
            .disposed(by: disposeBag)
    }

    // MARK: - Public

    public var passCodeTextValue: String? {
        return passCodeText.value
    }

    public func setPassCodeText(_ value: String?) {
        passCodeText.value = value
    }

    public func reset() {
        passCodeText.value = nil
        validationResultHolder.value = nil
        passCodeControllerStateVariable.value = operationType == .change ? .oldEnter : .enter
        attemptsNumber = 0
        passCodeHolder.reset()
    }

    public func authenticateUsingBiometrics(with description: String, fallback: String?, cancel: String?) {
        biometricsAuthBegins()
        biometricsService.authenticateWithBiometrics(with: description,
                                                     fallback: fallback,
                                                     cancel: cancel) { [weak self] success, error in
            self?.biometricsAuthEnds()
            if success {
                self?.authSucceed(.touchId)
            } else {
                self?.authFailed(with: error)
            }
        }
    }

    // MARK: - HAVE TO OVERRIDE

    /// Override to check if entered pass code is equal to stored
    open func isEnteredPassCodeValid(_ passCode: String) -> Bool {
        assertionFailure("You should override this method: isEnteredPassCodeValid(_ passCode: String)")
        return false
    }

    /// Method is called after successful authentication
    open func authSucceed(_ type: PassCodeAuthType) {
        assertionFailure("You should override this method: authSucceed(_ type: PassCodeAuthType)")
    }

    /// Called when authentication failed
    open func authFailed(with: Error?) {
        assertionFailure("You should override this method: authFailed(with: Error)")
    }

    // MARK: - Biometrics

    /// Posibility to use biometrics for authentication
    open var isBiometricsEnabled: Bool {
        return false
    }

    /// Notify about activation for biometrics. Remember to save user choice
    open func activateBiometricsForUser() {
        assertionFailure("You should override this method: activateBiometricsForUser()")
    }

    /// Notify before system alert with biometrics
    open func biometricsAuthBegins() {}

    /// Notify after system alert with biometrics
    open func biometricsAuthEnds() {}

}

private extension BasePassCodeViewModel {
    var validationResultBinder: Binder<PassCodeValidationResult?> {
        return Binder(self) { model, validationResult in
            let isValid = validationResult?.isValid ?? false
            let passCode = validationResult?.passCode

            if model.passCodeHolder.type == .change {
                if isValid, model.passCodeHolder.enterStep == .repeatEnter, let passCode = passCode {
                    model.authSucceed(.passCode(passCode))
                } else {
                    model.passCodeControllerStateVariable.value = model.passCodeHolder.enterStep
                }
            } else {
                if isValid, let passCode = passCode {
                    model.authSucceed(.passCode(passCode))
                } else {
                    model.passCodeControllerStateVariable.value = model.passCodeHolder.enterStep
                }
            }
        }
    }
}

extension BasePassCodeViewModel {

    private func set(passCode: String) {
        passCodeHolder.add(passCode: passCode)
        validateIfNeeded()

        if shouldUpdateControllerState {
            passCodeControllerStateVariable.value = passCodeHolder.enterStep
        }
    }

    private var shouldUpdateControllerState: Bool {
        return !passCodeHolder.shouldValidate ||
            !(validationResultHolder.value?.isValid ?? true) ||
            validationResultHolder.value?.error?.isTooManyAttempts ?? false
    }

    private func validateIfNeeded() {
        guard passCodeHolder.shouldValidate else {
            return
        }

        switch passCodeHolder.type {
        case .create where passCodeHolder.enterStep == .repeatEnter:
            attemptsNumber += 1
        case .change where passCodeHolder.enterStep == .repeatEnter:
            attemptsNumber += 1
        case .enter:
            attemptsNumber += 1
        default:
            break
        }

        var validationResult = passCodeHolder.validate()

        // if entered (in .enter mode) code is invalid -> .wrongCode
        if passCodeHolder.type == .enter,
            let passCode = validationResult.passCode,
            !isEnteredPassCodeValid(passCode) {

            let remainingAttemptsCount = passCodeConfiguration.maxAttemptsNumber - attemptsNumber
            validationResult = .invalid(.wrongCode(attemptsRemaining: remainingAttemptsCount))
        }

        // if entered code (in any mode) is mismatched too many times -> .tooManyAttempts
        if (!validationResult.isValid && attemptsNumber == passCodeConfiguration.maxAttemptsNumber) ||
            attemptsNumber > passCodeConfiguration.maxAttemptsNumber {
            validationResult = .invalid(.tooManyAttempts(type: operationType))
        }

        if !validationResult.isValid {
            passCodeHolder.reset()
        }

        validationResultHolder.value = validationResult
    }

}
