//
//  Copyright (c) 2017 Touch Instinct
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

public enum PinImageType {
    case entered
    case clear
}

public enum PassCodeControllerType {
    case create
    case enter
}

public enum PassCodeControllerState {
    case enter
    case repeatEnter
}

open class BasePassCodeViewController: UIViewController {

    public var viewModel: BasePassCodeViewModel!

    // MARK: - IBOutlets

    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet public weak var errorLabel: UILabel?
    @IBOutlet public weak var dotStackView: UIStackView!

    let disposeBag = DisposeBag()

    fileprivate lazy var fakeTextField: UITextField = {
        let fakeTextField = UITextField()
        fakeTextField.isSecureTextEntry = true
        fakeTextField.keyboardType = .numberPad
        fakeTextField.isHidden = true
        self.view.addSubview(fakeTextField)
        return fakeTextField
    }()

    // MARK: - Life circle

    override open func viewDidLoad() {
        super.viewDidLoad()

        initialLoadView()
        initialDotNumberConfiguration()
        enebleKeyboard()
        configureBackgroundNotifications()
        showTouchIdIfNeeded(with: touchIdHint)
    }

    // MARK: - Private functions

    private func configureBackgroundNotifications() {
        guard viewModel.passCodeConfiguration.shouldResetWhenGoBackground else {
            return
        }

        NotificationCenter.default.rx.notification(.UIApplicationWillResignActive)
            .subscribe(onNext: { [weak self] _ in
                self?.resetUI()
            })
            .addDisposableTo(disposeBag)
    }

    private func enebleKeyboard() {
        fakeTextField.becomeFirstResponder()
    }

    private func initialDotNumberConfiguration() {
        dotStackView.arrangedSubviews.forEach { dotStackView.removeArrangedSubview($0) }

        for _ in 0..<viewModel.passCodeConfiguration.passCodeCharactersNumber {
            let dotImageView = UIImageView()
            dotImageView.translatesAutoresizingMaskIntoConstraints = false
            dotImageView.widthAnchor.constraint(equalTo: dotImageView.heightAnchor, multiplier: 1)
            dotImageView.contentMode = .scaleAspectFit
            dotStackView.addArrangedSubview(dotImageView)
        }

        resetDotsUI()
    }

    fileprivate func resetDotsUI() {
        fakeTextField.text = nil
        dotStackView.arrangedSubviews
            .flatMap { $0 as? UIImageView }
            .forEach { $0.image = self.imageFor(type: .clear) }
    }

    private func setState(_ state: PinImageType, at index: Int) {
        guard dotStackView.arrangedSubviews.count > index,
            let imageView = dotStackView.arrangedSubviews[index] as? UIImageView else {
                return
        }

        imageView.image = imageFor(type: state)
    }

    fileprivate func setStates(for passCodeText: String) {
        var statesArray: [PinImageType] = []

        for characterIndex in 0..<viewModel.passCodeConfiguration.passCodeCharactersNumber {
            let state: PinImageType = Int(characterIndex) <= passCodeText.characters.count - 1 ? .entered : .clear
            statesArray.append(state)
        }

        statesArray.enumerated().forEach {
            self.setState($0.element, at: $0.offset)
        }
    }

    fileprivate func showTouchIdIfNeeded(with description: String) {
        guard viewModel.isTouchIdEnabled else {
            return
        }

        viewModel.touchIdService?.authenticateByTouchId(description: description) { [weak self] isSuccess in
            if isSuccess {
                self?.viewModel.authSucceed(.touchId)
            }
        }
    }

    fileprivate func resetUI() {
        resetDotsUI()
        viewModel.reset()
    }

    // MARK: - HAVE TO OVERRIDE

    open var touchIdHint: String {
        assertionFailure("You should override this var: touchIdHint")
        return ""
    }

    // override to change Images
    func imageFor(type: PinImageType) -> UIImage {
        assertionFailure("You should override this method: imageFor(type: PinImageType)")
        return UIImage()
    }

    // override to change error text
    func errorDescription(for error: PassCodeError) -> String {
        assertionFailure("You should override this method: errorDescription(for error: PassCodeError)")
        return ""
    }

    // override to change action title text
    func actionTitle(for passCodeControllerState: PassCodeControllerState) -> String {
        assertionFailure("You should override this method: actionTitle(for passCodeControllerState: PassCodeControllerState)")
        return ""
    }

    // MARK: - Functions that can you can override to castomise your controller

    open func showError(for error: PassCodeError) {
        errorLabel?.text = errorDescription(for: error)
        errorLabel?.isHidden = false
    }

    open func hideError() {
        errorLabel?.isHidden = true
    }

    // override to change UI for state
    open func configureUI(for passCodeControllerState: PassCodeControllerState) {
        resetDotsUI()
        titleLabel?.text = actionTitle(for: passCodeControllerState)
    }

}

// We need to implement all functions of ConfigurableController protocol to give ability to override them.
extension BasePassCodeViewController: ConfigurableController {

    open func bindViews() {
        fakeTextField.rx.text.asDriver()
            .do(onNext: { [weak self] text in
                self?.setStates(for: text ?? "")
                self?.hideError()
            })
            .drive(viewModel.passCodeText)
            .addDisposableTo(disposeBag)

        viewModel.validationResult
            .drive(onNext: { [weak self] validationResult in
                guard let validationResult = validationResult else {
                    return
                }

                if validationResult.isValid {
                    self?.hideError()
                } else if let pasCodeError = validationResult.error {
                    self?.showError(for: pasCodeError)
                }
            })
            .addDisposableTo(disposeBag)

        viewModel.passCodeControllerState
            .drive(onNext: { [weak self] controllerState in
                self?.configureUI(for: controllerState)
            })
            .addDisposableTo(disposeBag)
    }

    open func addViews() {}

    open func setAppearance() {}

    open func configureBarButtons() {}

    open func localize() {}

}
