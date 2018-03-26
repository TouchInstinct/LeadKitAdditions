import SwiftValidator
import RxSwift
import RxCocoa

public enum ValidationItemState {
    case initial
    case correction(ValidationError)
    case error(ValidationError)
    case valid
}

public extension ValidationItemState {

    var isInitial: Bool {
        switch self {
        case .initial:
            return true
        default:
            return false
        }
    }

    var isValid: Bool {
        switch self {
        case .valid:
            return true
        default:
            return false
        }
    }

}

public final class ValidationItem {

    private let disposeBag = DisposeBag()

    private let validationStateHolder = Variable<ValidationItemState>(.initial)
    public var validationState: ValidationItemState {
        return validationStateHolder.value
    }
    public var validationStateObservable: Observable<ValidationItemState> {
        return validationStateHolder.asObservable()
    }

    private let text = Variable<String?>(nil)

    private(set) var rules: [Rule] = []

    public init(rules: [Rule], textDriver: Driver<String?>) {
        self.rules = rules

        bindText(textDriver: textDriver)
    }

    private func bindText(textDriver: Driver<String?>) {
        textDriver
            .drive(text)
            .disposed(by: disposeBag)

        textDriver.asObservable().withLatestFrom(validationStateHolder.asObservable()) { (text: $0, validationState: $1) }
            .filter { !$0.validationState.isInitial }
            .map { $0.text }
            .subscribe(onNext: { [weak self] text in
                self?.validate(text: text)
            })
            .disposed(by: disposeBag)
    }

    public func manualValidate() -> Bool {
        validate(text: text.value, isManual: true)

        return validationStateHolder.value.isValid
    }

    private func validate(text: String?, isManual: Bool = false) {
        let error = rules.filter {
            !$0.validate(text ?? "")
        }
        .map { rule -> ValidationError in
            ValidationError(failedRule: rule, errorMessage: rule.errorMessage())
        }
        .first

        if let validationError = error {
            switch validationStateHolder.value {
            case .error where !isManual,
                 .correction where !isManual,
                 .valid where !isManual:

                validationStateHolder.value = .correction(validationError)
            default:
                validationStateHolder.value = .error(validationError)
            }
        } else {
            validationStateHolder.value = .valid
        }
    }

}
