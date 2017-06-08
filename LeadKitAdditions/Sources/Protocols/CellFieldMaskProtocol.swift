protocol CellFieldMaskProtocol {

    var haveMask: Bool { get }
    var maskFieldTextProxy: MaskFieldTextProxy? { get set }

}

extension CellFieldMaskProtocol {

    var haveMask: Bool {
        return maskFieldTextProxy != nil
    }
    
}
