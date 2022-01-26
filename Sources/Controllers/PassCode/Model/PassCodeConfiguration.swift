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

/// Configuration container for BasePassCodeViewController
public struct PassCodeConfiguration {

    /// Pass code length
    public let passCodeLength: Int

    /// Incorrect pass code attempts count
    public let maxAttemptsNumber: Int

    /// Clear input progress when application goes to background
    public let shouldResetWhenGoBackground: Bool

    public init(passCodeLength: Int = 4, maxAttemptsNumber: Int = 5, shouldResetWhenGoBackground: Bool = true) {
        self.passCodeLength = passCodeLength
        self.maxAttemptsNumber = maxAttemptsNumber
        self.shouldResetWhenGoBackground = shouldResetWhenGoBackground
    }

    /// Returns configuration with default values
    public static var defaultConfiguration: PassCodeConfiguration {
        PassCodeConfiguration()
    }
}
