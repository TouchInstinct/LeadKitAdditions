import RxSwift
import UIKit

enum CellFieldsToolBarType {
    case none
    case `default`
}

struct CellFieldsJumpingServiceConfig {

    var toolBarType: CellFieldsToolBarType = .default
    var toolBarNeedArrows = true

    init() {}

    init(toolBarType: CellFieldsToolBarType) {
        self.toolBarType = toolBarType
    }

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
                    .subscribe(onNext: {
                        if let nextActive = cellFields.nextActive(from: offset)  {
                            nextActive.shouldBecomeFirstResponder.onNext()
                        } else {
                            self.didDone.onNext()
                        }
                    })
                    .addDisposableTo(disposeBag)
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
                if let nextActive = self?.cellFields.nextActive(from: index)  {
                    nextActive.shouldBecomeFirstResponder.onNext()
                } else {
                    self?.didDone.onNext()
                }
            })
            .addDisposableTo(disposeBag)

        toolBar.shouldGoBackward.asObservable()
            .subscribe(onNext: { [weak self] in
                if let previousActive = self?.cellFields.previousActive(from: index)  {
                    previousActive.shouldBecomeFirstResponder.onNext()
                }
            })
            .addDisposableTo(disposeBag)

        toolBar.shouldEndEditing.asObservable()
            .subscribe(onNext: {
                field.shouldResignFirstResponder.onNext()
            })
            .addDisposableTo(disposeBag)

        return toolBar
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
        for (currentIndex, item) in enumerated() where currentIndex > index && item.isActive {
            return item
        }
        return nil
    }

    func previousActive(from index: Int) -> CellFieldJumpingProtocol? {
        let reversedIndex = count - index - 1
        for (currentIndex, item) in reversed().enumerated() where currentIndex > reversedIndex && item.isActive {
            return item
        }
        return nil
    }

}
