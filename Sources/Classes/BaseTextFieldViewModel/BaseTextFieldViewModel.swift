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
import SwiftValidator

/// Base implementation of TextFieldViewEvents.
open class BaseTextFieldViewEvents: TextFieldViewEvents {

    public let textChangedDriver: Driver<String?>

    /// Memberwise initializer.
    ///
    /// - Parameter textChangedDriver: Driver that emits text changes from a view.
    public init(textChangedDriver: Driver<String?>) {
        self.textChangedDriver = textChangedDriver
    }
}

/// Base implementation of text field view model events.
open class BaseTextFieldViewModelEvents: TextFieldViewModelEvents {

    public let setTextDriver: Driver<String?>
    public let changeValidationStateDriver: Driver<ValidationItemState>
    public let changeOnlineValidationStateDriver: Driver<OnlineValidationState>

    /// Memberwise initializer.
    ///
    /// - Parameters:
    ///   - setTextDriver: Driver that emit text that should be set inside a view.
    ///   - changeValidationStateDriver: Driver that emit validation state changes events.
    ///   - changeOnlineValidationStateDriver: Driver that emit online validation state changes events.
    public init(setTextDriver: Driver<String?>,
                changeValidationStateDriver: Driver<ValidationItemState>,
                changeOnlineValidationStateDriver: Driver<OnlineValidationState>) {

        self.setTextDriver = setTextDriver
        self.changeValidationStateDriver = changeValidationStateDriver
        self.changeOnlineValidationStateDriver = changeOnlineValidationStateDriver
    }
}

public extension BaseTextFieldViewModelEvents {

    /// Method that binds text driver to validation service via validation rules.
    ///
    /// - Parameters:
    ///   - textDriver: Driver that emits text changes.
    ///   - rules: Rules to validate for.
    ///   - validationService: Validation service to register in.
    /// - Returns: Driver that emit validation state changes.
    static func offlineValidationDriver(with textDriver: Driver<String?>,
                                        using rules: [Rule] = [RequiredRule()],
                                        in validationService: ValidationService) -> Driver<ValidationItemState> {

        let validationItem = ValidationItem(rules: rules, textDriver: textDriver)

        validationService.register(item: validationItem)

        let validationStateDriver = validationItem
            .validationStateObservable
            .asDriver(onErrorJustReturn: .initial)

        return validationStateDriver
    }

    typealias OnlineValidationClosure = (String) -> Single<OnlineValidateable>

    /// Method that binds text driver to validation chain (offline validation -> online validation)
    /// and returns online validation state driver.
    ///
    /// - Parameters:
    ///   - textDriver: Driver that emits text changes.
    ///   - offlineRules: Rules to validate before online validation will be requested.
    ///   - validationClosure: Closure that will be called for online validation request.
    /// - Returns: Driver that emit online validation state changes.
    static func onlineValidationDriver(with textDriver: Driver<String?>,
                                       using offlineRules: [Rule] = [],
                                       validationClosure: @escaping OnlineValidationClosure) -> Driver<OnlineValidationState> {

        return textDriver.flatMap { string -> Driver<OnlineValidationState> in
            guard let nonEmptyString = string, !nonEmptyString.isEmpty else {
                return .just(.initial)
            }

            let passedRules = offlineRules
                .map { $0.validate(nonEmptyString) }
                .reduce(true) { $0 && $1 }

            guard passedRules else {
                return .just(.initial)
            }

            let validationDriver = validationClosure(nonEmptyString).map { result -> OnlineValidationState in
                if result.isValid {
                    return .valid
                } else {
                    return .invalid(error: result.error)
                }
            }
            .asDriver(onErrorJustReturn: .initial)

            return Driver.merge([.just(.initial), .just(.processing), validationDriver])
        }
    }

    /// Convenience initializer with offline and online validation.
    ///
    /// - Parameters:
    ///   - binding: Data model field binding.
    ///   - rules: Rules to validate before online validation will be requested.
    ///   - validationService: Validation service to register in.
    ///   - onlineValidationClosure: Closure that will be called for online validation request.
    ///   - onlineValidationThrottle: Throttling duration for each text change.
    convenience init<T>(binding: DataModelFieldBinding<T>,
                        rules: [Rule] = [RequiredRule()],
                        validationService: ValidationService,
                        onlineValidationClosure: OnlineValidationClosure? = nil,
                        onlineValidationThrottle: RxTimeInterval = 0.5) {

        let dataModelFieldDriver = binding.fieldDriver

        let offlineValidationDriver = BaseTextFieldViewModelEvents.offlineValidationDriver(with: dataModelFieldDriver,
                                                                                           using: rules,
                                                                                           in: validationService)

        let onlineValidationDriver: Driver<OnlineValidationState>

        if let onlineValidationClosure = onlineValidationClosure {
            let throttledTextDriver = dataModelFieldDriver.throttle(onlineValidationThrottle)

            onlineValidationDriver = BaseTextFieldViewModelEvents
                .onlineValidationDriver(with: throttledTextDriver,
                                        using: rules,
                                        validationClosure: onlineValidationClosure)
        } else {
            onlineValidationDriver = .just(.initial)
        }

        self.init(setTextDriver: dataModelFieldDriver,
                  changeValidationStateDriver: offlineValidationDriver,
                  changeOnlineValidationStateDriver: onlineValidationDriver)
    }
}
