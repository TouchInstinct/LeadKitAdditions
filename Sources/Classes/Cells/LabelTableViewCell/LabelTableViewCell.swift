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

/// Pin layout cell with separators, background and label.
open class LabelTableViewCell: SeparatorTableViewCell {

    private let label = UILabel(frame: .zero)
    private let backgroundImageView = UIImageView(frame: .zero)
    private let contentContainerView = UIView(frame: .zero)

    private var viewModel: LabelCellViewModel?

    // MARK: - PinLayoutTableViewCell

    override open func addViews() {
        super.addViews()

        contentContainerView.addSubview(backgroundImageView)
        contentContainerView.addSubview(label)

        contentView.addSubview(contentContainerView)
    }

    override open func configureAppearance() {
        super.configureAppearance()

        selectionStyle = .none
        backgroundColor = .clear

        contentView.backgroundColor = .clear

        configureAppearance(of: label, backgroundImageView: backgroundImageView)
    }

    override open func layout() {
        let topSeparatorHeight = viewModel?.separatorType.topConfiguration?.totalHeight ?? 0
        let bottomSeparatorHeight = viewModel?.separatorType.bottomConfiguration?.totalHeight ?? 0

        contentContainerView.pin
            .top(topSeparatorHeight + contentInsets.top)
            .horizontally(contentInsets)
            .bottom(contentInsets.bottom + bottomSeparatorHeight)
            .layout()

        label.pin
            .top(labelInsets)
            .horizontally(labelInsets)
            .sizeToFit(.width)
            .layout()

        backgroundImageView.pin
            .all()
            .layout()

        // bottom separator positioning after content size (height) calculation
        super.layout()
    }

    private var labelInsets: UIEdgeInsets {
        return viewModel?.labelInsets ?? .zero
    }

    private var contentInsets: UIEdgeInsets {
        return viewModel?.contentInsets ?? .zero
    }

    override open var contentHeight: CGFloat {
        let selfContentHeight = contentInsets.top +
            labelInsets.top +
            label.frame.height +
            labelInsets.bottom +
            contentInsets.bottom

        return selfContentHeight + super.contentHeight
    }

    // MARK: - Subclass methods to override

    /// Callback for label and background image view appearance configuration.
    ///
    /// - Parameters:
    ///   - label: Internal UILabel instance to configure.
    ///   - backgroundImageView: Internal UIImageView instance to configure.
    open func configureAppearance(of label: UILabel, backgroundImageView: UIImageView) {
        label.numberOfLines = 0
    }

    // MARK: - Configuration methods

    /// Convenient method for configuration cell with LabelCellViewModel.
    ///
    /// - Parameter viewModel: LabelCellViewModel instance.
    public func configureLabelCell(with viewModel: LabelCellViewModel) {
        self.viewModel = viewModel

        configureSeparator(with: viewModel.separatorType)
        configureLabelText(with: viewModel.viewText)
        configureContentBackground(with: viewModel.contentBackground)

        setNeedsLayout()
    }

    /// Method for background configuration.
    ///
    /// - Parameter contentBackground: Content background to use as background.
    public func configureContentBackground(with contentBackground: ViewBackground) {
        contentBackground.configure(backgroundView: contentContainerView,
                                    backgroundImageView: backgroundImageView)
    }

    /// Method for text configuration.
    ///
    /// - Parameter viewText: View text to use as background.
    public func configureLabelText(with viewText: ViewText) {
        label.configure(with: viewText)
    }

}
