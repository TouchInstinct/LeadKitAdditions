import UIKit
import RxSwift

protocol CellFieldsToolBarProtocol: class {

    var needArrows: Bool { get set }

    var canGoForward: Bool { get set }
    var canGoBackward: Bool { get set }

    var shouldGoForward: PublishSubject<Void> { get }
    var shouldGoBackward: PublishSubject<Void> { get }

    var shouldEndEditing: PublishSubject<Void> { get }

}
