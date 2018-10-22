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

/// Holds information about enter type (create, change, etc), step
/// Also describes interface to manipulate with entered pass code
public protocol PassCodeHolderProtocol {

    /// Type of operation with pass code
    var type: PassCodeOperationType { get }
    /// Operation step
    var enterStep: PassCodeControllerState { get }

    /// Add pass code for current step
    func add(passCode: String)
    /// Reset all progress
    func reset()

    /// Should been pass code validated
    var shouldValidate: Bool { get }
    /// Current pass code
    var passCode: String? { get }

    /// Returns passCode or error if pass code is invalid
    func validate() -> PassCodeValidationResult

}

public class PassCodeHolderBuilder {

    private init() {}

    /**
     Creates holder by type (create, change, etc)

      - parameter type: type of pass code controller
      - returns: pass code information holder, specific by type
     */
    public static func build(with type: PassCodeOperationType) -> PassCodeHolderProtocol {
        switch type {
        case .create:
            return PassCodeHolderCreate()
        case .enter:
            return PassCodeHolderEnter()
        case .change:
            return PassCodeHolderChange()
        }
    }

}
