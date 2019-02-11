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

import CoreGraphics.CGBase

/// Protocol with methods for configuration and layout cell.
public protocol PinLayoutCell {

    /// Method is called when cell initialized from nib or from code.
    func initializeCell()

    /// Method for adding subviews to content view.
    ///
    /// - Returns: Nothing.
    func addViews()

    /// Method for cofiguring appearance of views.
    ///
    /// - Returns: Nothing.
    func configureAppearance()

    /// Method for cofiguring layout and layout properties.
    ///
    /// - Returns: Nothing.
    func configureLayout()

    /// Method is called during layout calls.
    ///
    /// - Returns: Nothing.
    func layout()

    /// Method for calculating best-fitting cell size.
    ///
    /// - Parameter containerSize: The size for which the view should calculate its best-fitting size.
    /// - Returns: Best-fitting size.
    func layout(with containerSize: CGSize) -> CGSize

    /// Current content height.
    var contentHeight: CGFloat { get }
}
