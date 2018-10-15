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

import UIKit
import RxSwift
import RxCocoa
import LeadKit

/// Describes pin image
public enum PinImageType {
    case entered
    case clear
}

/// Pass code operation type
public enum PassCodeControllerType {
    case create
    case enter
    case change
}

/// Pass code operation state
public enum PassCodeControllerState {
    case enter
    case repeatEnter
    case oldEnter
    case newEnter
}

/// Base view controller that operates with pass code
open class BasePassCodeViewController: UIViewController, ConfigurableController {

    public let viewModel: BasePassCodeViewModel

    public init(viewModel: BasePassCodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var errorLabel: UILabel?
    @IBOutlet private weak var dotStackView: UIStackView!

    public let disposeBag = DisposeBag()
    private var delayedErrorDescriptions: Disposable?

    private lazy var fakeTextField: UITextField = {
        let fakeTextField = UITextField()
        fakeTextField.isSecureTextEntry = true
        fakeTextField.keyboardType = .numberPad
        fakeTextField.isHidden = true
        fakeTextField.delegate = self
        self.view.addSubview(fakeTextField)
        return fakeTextField
    }()

    // MARK: - Life circle

    override open func viewDidLoad() {
        super.viewDidLoad()

        initialLoadView()
        initialDotNumberConfiguration()
        configureBackgroundNotifications()
        showBiometricsRequestIfNeeded()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fakeTextField.becomeFirstResponder()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fakeTextField.resignFirstResponder()
    }

    // MARK: - Private functions

    private func configureBackgroundNotifications() {
        guard viewModel.passCodeConfiguration.shouldResetWhenGoBackground else {
            return
        }

        NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.resetUI()
            })
            .disposed(by: disposeBag)
    }

    private func initialDotNumberConfiguration() {
        dotStackView.arrangedSubviews.forEach { dotStackView.removeArrangedSubview($0) }

        for _ in 0 ..< viewModel.passCodeConfiguration.passCodeLength {
            let dotImageView = UIImageView()
            dotImageView.translatesAutoresizingMaskIntoConstraints = false
            dotImageView.widthAnchor.constraint(equalTo: dotImageView.heightAnchor, multiplier: 1)
            dotImageView.contentMode = .scaleAspectFit
            dotStackView.addArrangedSubview(dotImageView)
        }

        resetDotsUI()
    }

    private func resetDotsUI() {
        fakeTextField.text = nil
        dotStackView.arrangedSubviews
            .compactMap { $0 as? UIImageView }
            .forEach { $0.image = self.imageFor(type: .clear) }
    }

    private func setState(_ state: PinImageType, at index: Int) {
        guard dotStackView.arrangedSubviews.count > index,
            let imageView = dotStackView.arrangedSubviews[index] as? UIImageView else {
                return
        }

        imageView.image = imageFor(type: state)
    }

    private func setStates(for passCodeText: String) {
        var statesArray: [PinImageType] = []

        for characterIndex in 0..<viewModel.passCodeConfiguration.passCodeLength {
            let state: PinImageType = Int(characterIndex) <= passCodeText.count - 1 ? .entered : .clear
            statesArray.append(state)
        }

        statesArray.enumerated().forEach {
            self.setState($0.element, at: $0.offset)
        }
    }

    private func showBiometricsRequestIfNeeded() {
        guard viewModel.isBiometricsEnabled && viewModel.controllerType == .enter else {
            return
        }

        viewModel.authenticateUsingBiometrics(with: biometricsAuthorizationHint,
                                              fallback: biometricsFallbackButtonTitle,
                                              cancel: biometricsCancelButtonTitle)
    }

    private func resetUI() {
        resetDotsUI()
        viewModel.reset()
    }

    // MARK: - HAVE TO OVERRIDE

    /// Returns prompt that appears on touch id system alert
    open var biometricsAuthorizationHint: String {
        assertionFailure("You should override this \(#function)")
        return ""
    }

    /// Returns prompt that appears on touch id system alert
    open var biometricsFallbackButtonTitle: String? {
        assertionFailure("You should override this \(#function)")
        return nil
    }

    /// Returns prompt that appears on touch id system alert
    open var biometricsCancelButtonTitle: String? {
        assertionFailure("You should override this \(#function)")
        return nil
    }

    /// Override to point certain images
    open func imageFor(type: PinImageType) -> UIImage {
        assertionFailure("You should override this method: imageFor(type: PinImageType)")
        return UIImage()
    }

    /// Override to change error description
    open func errorDescription(for error: PassCodeError) -> [PassCodeDelayedDescription] {
        assertionFailure("You should override this method: errorDescription(for error: PassCodeError)")
        return []
    }

    /// Override to change action title text
    open func actionTitle(for passCodeControllerState: PassCodeControllerState) -> NSAttributedString {
        assertionFailure("You should override this method: actionTitle(for passCodeControllerState: PassCodeControllerState)")
        return NSAttributedString(string: "")
    }

    // MARK: - Functions that you can override to customize your controller

    /// Call to show error
    open func showError(for error: PassCodeError) {
        let descriptionsObservables = errorDescription(for: error)
            .sorted { $0.delay < $1.delay }
            .map { [weak self] delayedDescription in
                Observable<Int>
                    .interval(delayedDescription.delay, scheduler: MainScheduler.instance)
                    .take(1)
                    .do(onNext: { _ in
                        self?.errorLabel?.attributedText = delayedDescription.description
                    })
            }

        delayedErrorDescriptions?.dispose()

        errorLabel?.attributedText = nil
        errorLabel?.isHidden = false

        delayedErrorDescriptions = Observable
            .merge(descriptionsObservables)
            .subscribe()
    }

    /// Call to disappear error label
    open func hideError() {
        errorLabel?.isHidden = true
    }

    /// Override to change UI for state
    open func configureUI(for passCodeControllerState: PassCodeControllerState) {
        resetDotsUI()
        titleLabel?.attributedText = actionTitle(for: passCodeControllerState)
    }

    // MARK: - Public functions

    /// Make fakeTextField become first responder
    public func enableInput() {
        fakeTextField.becomeFirstResponder()
    }

    /// Make fakeTextField resign first responder
    public func disableInput() {
        fakeTextField.resignFirstResponder()
    }

    // MARK: - ConfigurableController

    open func bindViews() {
        fakeTextField.rx.text.asDriver()
            .do(onNext: { [weak self] text in
                self?.setStates(for: text ?? "")
                self?.hideError()
            })
            .delay(0.1)     // time to draw dots
            .drive(onNext: { [weak self] text in
                self?.viewModel.setPassCodeText(text)
            })
            .disposed(by: disposeBag)

        viewModel.validationResultDriver
            .drive(onNext: { [weak self] validationResult in
                guard let validationResult = validationResult else {
                    return
                }

                if validationResult.isValid {
                    self?.hideError()
                } else if let passCodeError = validationResult.error {
                    self?.showError(for: passCodeError)
                }
            })
            .disposed(by: disposeBag)

        viewModel.passCodeControllerStateDriver
            .drive(onNext: { [weak self] controllerState in
                self?.configureUI(for: controllerState)
            })
            .disposed(by: disposeBag)
    }

    open func addViews() {}

    open func configureAppearance() {}

    open func configureBarButtons() {}

    open func localize() {}
}

// MARK: - UITextFieldDelegate

extension BasePassCodeViewController: UITextFieldDelegate {

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        let invalid = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalid, options: [], range: string.startIndex..<string.endIndex) == nil
    }

}
