import UIKit
import RxCocoa
import RxSwift

class CellTextField: UITextField {

    private var disposeBag = DisposeBag()

    var viewModel: CellTextFieldViewModel? {
        didSet {
            configure()
        }
    }

    // MARK: - Init

    private func configure() {
        disposeBag = DisposeBag()

        guard let viewModel = viewModel else {
            return
        }

        inputAccessoryView = viewModel.toolBar
        returnKeyType = viewModel.returnButtonType

        text = viewModel.text.value
        placeholder = viewModel.placeholder
        viewModel.textFieldSettingsBlock?(self)

        viewModel.bind(for: self, to: disposeBag)

        rx.text.asDriver()
            .drive(viewModel.text)
            .addDisposableTo(disposeBag)

        rx.controlEvent(.editingDidEndOnExit).asObservable()
            .subscribe(onNext: {
                viewModel.shouldGoForward.onNext()
            })
            .addDisposableTo(disposeBag)
    }

}
