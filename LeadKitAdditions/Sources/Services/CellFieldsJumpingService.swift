import RxSwift
import UIKit

struct CellFieldsJumpingServiceConfig {

    var toolBarNeedArrows = true

    init() {}

    static var `default`: CellFieldsJumpingServiceConfig {
        return CellFieldsJumpingServiceConfig()
    }

}

class CellFieldsJumpingService {

    private var disposeBag = DisposeBag()

    // MARK: - Private properties

    private var cellFields: [CellFieldJumpingProtocol] = []

    // MARK: - Public propertries

    var config: CellFieldsJumpingServiceConfig = .default {
        didSet {
            configure()
        }
    }

    let didDone = PublishSubject<Void>()

    // MARK: - Initialization

    init() {}

    // MARK: - Public

    func removeAll() {
        cellFields.removeAll()
        disposeBag = DisposeBag()
    }

    func add(fieled: CellFieldJumpingProtocol, shouldConfigure: Bool = true) {
        add(fieleds: [fieled], shouldConfigure: shouldConfigure)
    }

    func add(fieleds: [CellFieldJumpingProtocol], shouldConfigure: Bool = true) {
        cellFields += fieleds

        if shouldConfigure {
            configure()
        }
    }

    func configure() {
        disposeBag = DisposeBag()

        let cellFields = self.cellFields

        cellFields
            .filter { $0.isActive }
            .enumerated()
            .forEach { offset, field in
                field.toolBar = toolBar(for: field, with: offset)
                field.returnButtonType = .next

                field.shouldGoForward.asObservable()
                    .subscribe(onNext: { [weak self] in
                        self?.shouldGoForwardAction(from: offset)
                    })
                    .disposed(by: disposeBag)
            }

        cellFields.lastActive?.returnButtonType = .done
    }

    private func toolBar(for field: CellFieldJumpingProtocol, with index: Int) -> UIToolbar {
        let toolBar = CellTextFieldToolBar()
        toolBar.canGoForward = cellFields.nextActive(from: index) != nil
        toolBar.canGoBackward = cellFields.previousActive(from: index) != nil

        toolBar.needArrows = config.toolBarNeedArrows

        toolBar.shouldGoForward.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.shouldGoForwardAction(from: index)
            })
            .disposed(by: disposeBag)

        toolBar.shouldGoBackward
            .subscribe(onNext: { [weak self] in
                if let previousActive = self?.cellFields.previousActive(from: index) {
                    previousActive.shouldBecomeFirstResponder.onNext(Void())
                }
            })
            .disposed(by: disposeBag)

        toolBar.shouldEndEditing
            .subscribe(onNext: { [field] in
                field.shouldResignFirstResponder.onNext(Void())
            })
            .disposed(by: disposeBag)

        return toolBar
    }

    private func shouldGoForwardAction(from index: Int) {
        if let nextActive = cellFields.nextActive(from: index) {
            nextActive.shouldBecomeFirstResponder.onNext(Void())
        } else {
            didDone.onNext(Void())
        }
    }

}

extension Array where Element == CellFieldJumpingProtocol {

    var firstActive: CellFieldJumpingProtocol? {
        return first { $0.isActive }
    }

    var lastActive: CellFieldJumpingProtocol? {
        return reversed().first { $0.isActive }
    }

    func nextActive(from index: Int) -> CellFieldJumpingProtocol? {
        return enumerated().first { $0 > index && $1.isActive }?.element
    }

    func previousActive(from index: Int) -> CellFieldJumpingProtocol? {
        let reversedIndex = count - index - 1
        return reversed().enumerated().first { $0 > reversedIndex && $1.isActive }?.element
    }

}
