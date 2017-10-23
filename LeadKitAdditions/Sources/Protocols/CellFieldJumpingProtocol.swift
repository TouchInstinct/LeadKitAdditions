import RxSwift
import RxCocoa
import UIKit

typealias ItemSettingsBlock<UIItem> = (UIItem) -> Void where UIItem: UIView

protocol CellFieldJumpingProtocol: FormCellViewModelProtocol {

    var toolBar: UIToolbar? { get set }

    var shouldGoForward: PublishSubject<Void> { get }

    var shouldBecomeFirstResponder: PublishSubject<Void> { get }
    var shouldResignFirstResponder: PublishSubject<Void> { get }

    var returnButtonType: UIReturnKeyType { get set }

}

extension CellFieldJumpingProtocol {

    func bind(for textField: UITextField, to disposeBag: DisposeBag) {
        shouldResignFirstResponder.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak textField] _ in
                textField?.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        shouldBecomeFirstResponder.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak textField] _ in
                textField?.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }

}
