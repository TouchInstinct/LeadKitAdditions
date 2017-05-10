//
//  Copyright (c) 2017 Touch Instinct
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

extension Array where Element: Equatable {

    public func union(values: [Array.Element]...) -> Array {
        var result = self

        for array in values {
            for value in array {
                if !result.contains(value) {
                    result.append(value)
                }
            }
        }

        return result
    }

    public func intersection(values: [Array.Element]...) -> Array {
        var result = self
        var intersection = Array()

        for (index, value) in values.enumerated() {
            if index > 0 {
                result = intersection
                intersection = Array()
            }

            value.forEach { item in
                if result.contains(item) && !intersection.contains(item) {
                    intersection.append(item)
                }
            }
        }

        return intersection
    }

    public func subtract(values: [Array.Element]...) -> Array {
        var result = Array()

        elements: for item in self {
            for value in values {
                if value.contains(item) {
                    continue elements
                }
            }

            result.append(item)
        }

        return result
    }

}
