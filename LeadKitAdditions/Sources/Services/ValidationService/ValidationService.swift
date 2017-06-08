import SwiftValidator
import RxCocoa
import RxSwift

private enum ValidationServiceStateReactType {
    case none
    case all
    case each
}

enum ValidationServiceState {
    case initial
    case valid
    case invalid
}

extension ValidationServiceState {

    var isValid: Bool {
        return self == .valid
    }

}

class ValidationService {

    private var disposeBag = DisposeBag()

    private(set) var validationItems: [ValidationItem] = []

    private let stateHolder: Variable<ValidationServiceState> = Variable(.initial)
    var state: ValidationServiceState {
        return stateHolder.value
    }
    var stateObservable: Observable<ValidationServiceState> {
        return stateHolder.asObservable()
    }

    private var validationStateReactType: ValidationServiceStateReactType = .none

    func register(item: ValidationItem) {
        register(items: [item])
    }

    func register(items: [ValidationItem]) {
        validationItems += items
        bindItems()
    }

    func unregisterAll() {
        validationItems.removeAll()
        bindItems()
    }

    func unregister(item: ValidationItem) {
        unregister(items: [item])
    }

    func unregister(items: [ValidationItem]) {
        items.forEach { item in
            if let removeIndex = validationItems.index(where: { $0 === item }) {
                validationItems.remove(at: removeIndex)
            }
        }

        bindItems()
    }

    @discardableResult
    func validate() -> Bool {
        validationStateReactType = .all
        let isValid = validationItems.map { $0.manualValidate()}.reduce(true) { $0 && $1 }
        validationStateReactType = .each

        return isValid
    }

    private func bindItems() {
        disposeBag = DisposeBag()

        let allValidationStateObservables = validationItems.map { $0.validationStateObservable }

        let zipStates = Observable
            .zip(allValidationStateObservables) { $0 }
            .filter { [weak self] _ in self?.validationStateReactType == .all }

        let combineLatestStates = Observable
            .combineLatest(allValidationStateObservables) { $0 }
            .filter { [weak self] _ in self?.validationStateReactType == .each }

        let stateObservables = [zipStates, combineLatestStates]

        stateObservables.forEach { observable in
            observable
                .map { states -> Bool in
                    return states.map { $0.isValid }.reduce(true) { $0 && $1 }
                }
                .map { $0 ? ValidationServiceState.valid : .invalid }
                .bind(to: stateHolder)
                .addDisposableTo(disposeBag)
        }
    }

}
