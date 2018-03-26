import RxCocoa
import RxSwift

protocol FormCellViewModelProtocol: class {
    var isActive: Bool { get set }
}

extension FormCellViewModelProtocol {

    func activate(_ isActive: Bool) -> Self {
        self.isActive = isActive
        return self
    }

}
