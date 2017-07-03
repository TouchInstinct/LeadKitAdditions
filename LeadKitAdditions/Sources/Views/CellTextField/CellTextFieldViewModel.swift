import UIKit
import RxSwift

class CellTextFieldViewModel: CellFieldJumpingProtocol {

    let text: Variable<String?>
    let placeholder: String

    let textFieldSettingsBlock: ItemSettingsBlock<UITextField>?

    // MARK: - CellFieldJumpingProtocol

    var toolBar: UIToolbar?

    let shouldGoForward = PublishSubject<Void>()

    let shouldBecomeFirstResponder = PublishSubject<Void>()
    let shouldResignFirstResponder = PublishSubject<Void>()

    var returnButtonType: UIReturnKeyType = .default

    var isActive: Bool = true

    init(initialText: String = "", placeholder: String = "", textFieldSettingsBlock: ItemSettingsBlock<UITextField>? = nil) {
        text = Variable(initialText)
        self.placeholder = placeholder
        self.textFieldSettingsBlock = textFieldSettingsBlock
    }

}
