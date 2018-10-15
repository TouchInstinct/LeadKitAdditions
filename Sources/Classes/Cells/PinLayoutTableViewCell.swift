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
import PinLayout

/// Cell that uses PinLayout. Contains methods that should be overriden in subclasses.
open class PinLayoutTableViewCell: UITableViewCell, PinLayoutCell {

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initializeCell()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initializeCell()
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout(with: size)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        layout()
    }

    // MARK: - PinLayoutCell

    open func initializeCell() {
        addViews()
        configureAppearance()
        configureLayout()
    }

    open func layout(with containerSize: CGSize) -> CGSize {
        // 1) Set the contentView's width to the specified size parameter
        contentView.pin.width(containerSize.width).layout()

        // 2) Layout the contentView's controls
        layout()

        // 3) Returns a size that contains all controls
        return CGSize(width: contentView.frame.width,
                      height: contentHeight)
    }

    open func addViews() {
        // override in subclass

        // move from _UISnapshotWindow superview in Playground
        addSubview(contentView)
    }

    open func configureAppearance() {
        // override in subclass
    }

    open func configureLayout() {
        // override in subclass
    }

    open func layout() {
        // override in subclass
    }

    open var contentHeight: CGFloat {
        return contentView.subviewsMaxY
    }

}

private extension UIView {

    var subviewsMaxY: CGFloat {
        return subviews
            .map { $0.frame.maxY }
            .max() ?? frame.maxY
    }

}
