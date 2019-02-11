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
import LeadKit
import PinLayout

/// Pin layout cell with top and bottom separators.
open class SeparatorTableViewCell: PinLayoutTableViewCell {

    private let topSeparator = UIView(frame: .zero)
    private let bottomSeparator = UIView(frame: .zero)

    private var separatorType: CellSeparatorType = .none

    /// Configure separator with viewModel.
    /// - parameter separatorType: type of separators.
    public func configureSeparator(with separatorType: CellSeparatorType) {
        self.separatorType = separatorType

        separatorType.configure(topSeparatorView: topSeparator,
                                bottomSeparatorView: bottomSeparator)

        setNeedsLayout()
    }

    /// Move separator upward in hierarchy
    public func bringSeparatorsToFront() {
        contentView.bringSubviewToFront(topSeparator)
        contentView.bringSubviewToFront(bottomSeparator)
    }

    /// Move separator backward in hierarchy
    public func sendSeparatorsToBack() {
        contentView.sendSubviewToBack(topSeparator)
        contentView.sendSubviewToBack(bottomSeparator)
    }

    // MARK: - PinLayoutTableViewCell

    override open func addViews() {
        super.addViews()

        contentView.addSubviews(topSeparator, bottomSeparator)
    }

    override open func layout() {
        super.layout()

        if let topConfiguration = separatorType.topConfiguration {
            topSeparator.pin
                .top(topConfiguration.insets)
                .horizontally(topConfiguration.insets)
                .height(topConfiguration.height)
                .layout()
        }

        if let bottomConfiguration = separatorType.bottomConfiguration {
            let topInset = contentHeight - (bottomConfiguration.height + bottomConfiguration.insets.bottom)

            bottomSeparator.pin
                .top(topInset)
                .horizontally(bottomConfiguration.insets)
                .height(bottomConfiguration.height)
                .layout()
        }
    }

    override open var contentHeight: CGFloat {
        let topSeparatorHeight = separatorType.topConfiguration?.totalHeight ?? 0
        let bottomSeparatorHeight = separatorType.bottomConfiguration?.totalHeight ?? 0

        return topSeparatorHeight + bottomSeparatorHeight
    }

    // MARK: - UITableViewCell

    override open func prepareForReuse() {
        super.prepareForReuse()

        configureSeparator(with: .none)
    }
}
