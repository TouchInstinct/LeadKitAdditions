import InputMask
import RxCocoa
import RxSwift

class MaskFieldTextProxy: NSObject {

    private var disposeBag = DisposeBag()

    let text = Variable("")
    let isComplete = Variable(false)

    private(set) var field: UITextField?

    private let maskedProxy: PolyMaskTextFieldDelegate

    init(primaryFormat: String, affineFormats: [String] = []) {
        maskedProxy = PolyMaskTextFieldDelegate(primaryFormat: primaryFormat, affineFormats: affineFormats)

        super.init()

        maskedProxy.listener = self
    }

    func configure(with field: UITextField) {
        self.field = field
        field.delegate = maskedProxy
    }

    private func bindData() {
        disposeBag = DisposeBag()

        text.asDriver()
            .distinctUntilChanged()
            .drive(onNext: { [weak self] value in
                guard let textField = self?.field else {
                    return
                }

                self?.maskedProxy.put(text: value, into: textField)
            })
            .addDisposableTo(disposeBag)
    }

}

extension MaskFieldTextProxy: MaskedTextFieldDelegateListener {

    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        text.value = value
        isComplete.value = complete
    }

}
