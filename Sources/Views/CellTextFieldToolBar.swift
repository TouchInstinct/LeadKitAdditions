import UIKit
import RxSwift
import RxCocoa
import LeadKit

class CellTextFieldToolBar: UIToolbar, CellFieldsToolBarProtocol {

    private let buttonSpace: CGFloat = 20

    // MARK: - CellFieldsToolBarProtocol

    var needArrows: Bool = true

    var canGoForward: Bool = false {
        didSet {
            forwardButton.isEnabled = canGoForward
        }
    }
    var canGoBackward: Bool = false {
        didSet {
            backButton.isEnabled = canGoBackward
        }
    }

    var shouldGoForward = PublishSubject<Void>()
    var shouldGoBackward = PublishSubject<Void>()
    var shouldEndEditing = PublishSubject<Void>()

    // MARK: - UIBarButtonItems

    var backButtonImage: UIImage? {
        didSet {
            backButton.image = backButtonImage
        }
    }
    var forwardButtonImage: UIImage? {
        didSet {
            backButton.image = backButtonImage
        }
    }

    private(set) lazy var backButton: UIBarButtonItem = {
        let backButton = UIBarButtonItem(image: self.backButtonImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(backAction))
        return backButton
    }()

    private(set) lazy var forwardButton: UIBarButtonItem = {
        let forwardButton = UIBarButtonItem(image: self.forwardButtonImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(forwardAction))
        return forwardButton
    }()

    private(set) lazy var closeButton: UIBarButtonItem = {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(doneAction))
        return doneButton
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }

    private func initialization() {
        barStyle = .default
        isTranslucent = true
        tintColor = UIColor(hex6: 0x0A84DF)
        sizeToFit()

        let leftSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let firstButtonsSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        firstButtonsSpacer.width = buttonSpace
        let secondButtonsSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        secondButtonsSpacer.width = buttonSpace

        setItems([leftSpacer, backButton, firstButtonsSpacer, forwardButton, secondButtonsSpacer, closeButton], animated: true)
        items?.forEach { $0.tintColor = tintColor }
    }

    // MARK: - Actions

    @objc private func backAction() {
        shouldGoBackward.onNext(Void())
    }

    @objc private func forwardAction() {
        shouldGoForward.onNext(Void())
    }

    @objc private func doneAction() {
        shouldEndEditing.onNext(Void())
    }

}
