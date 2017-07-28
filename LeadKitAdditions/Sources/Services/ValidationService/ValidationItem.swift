import SwiftValidator
import RxSwift
import RxCocoa

enum ValidationItemState {
    case initial
    case correction(ValidationError)
    case error(ValidationError)
    case valid
}

extension ValidationItemState {

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

class ValidationItem {

    private let disposeBag = DisposeBag()

    private let validationStateHolder = Variable<ValidationItemState>(.initial)
    var validationState: ValidationItemState {
        return validationStateHolder.value
    }
    var validationStateObservable: Observable<ValidationItemState> {
        return validationStateHolder.asObservable()
    }

    private let text = Variable<String?>(nil)

    private(set) var rules: [Rule] = []

    init(rules: [Rule]) {
        self.rules = rules
        bindText()
    }

    private func bindText() {
        text.asObservable()
            .filter { [weak self] _ in !(self?.validationState.isInitial ?? true)}
            .subscribe(onNext: { [weak self] value in
                self?.validate(text: value)
            })
            .addDisposableTo(disposeBag)
    }

    @discardableResult
    func manualValidate() -> Bool {
        return validate(text: text.value, isManual: true)
    }

    @discardableResult
    private func validate(text: String?, isManual: Bool = false) -> Bool {
        let error = rules.filter {
                return !$0.validate(text ?? "")
            }
            .map { rule -> ValidationError in
                return ValidationError(failedRule: rule, errorMessage: rule.errorMessage())
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

        return validationStateHolder.value.isValid
    }

}
