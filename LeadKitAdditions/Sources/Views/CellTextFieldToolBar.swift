import UIKit
import RxSwift
import RxCocoa
import LeadKit

class CellTextFieldToolBar: UIToolbar, CellFieldsToolBarProtocol {

    private let buttonSpace: CGFloat = 20
    private let customSkyColor = UIColor(hex6: 0x0A84DF)

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

    private(set) lazy var backButton: UIBarButtonItem = {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "keyboard_back"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backAction))
        return backButton
    }()

    private(set) lazy var forwardButton: UIBarButtonItem = {
        let forwardButton = UIBarButtonItem(image: #imageLiteral(resourceName: "keyboard_forward"),
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
        sizeToFit()

        let leftSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttonsSpacer1 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        buttonsSpacer1.width = buttonSpace
        let buttonsSpacer2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        buttonsSpacer2.width = buttonSpace

        setItems([leftSpacer, backButton, buttonsSpacer1, forwardButton, buttonsSpacer2, closeButton], animated: true)
        items?.forEach { $0.tintColor = customSkyColor }
    }

    // MARK: - Actions

    @objc private func backAction() {
        shouldGoBackward.onNext()
    }

    @objc private func forwardAction() {
        shouldGoForward.onNext()
    }

    @objc private func doneAction() {
        shouldEndEditing.onNext()
    }

}
