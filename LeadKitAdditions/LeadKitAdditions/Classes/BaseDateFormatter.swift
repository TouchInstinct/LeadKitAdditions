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

import Foundation
import ObjectMapper

open class BaseDateFormatter {

    private static let apiDateTimeFormat           = "yyyy-MM-dd'T'HH:mm:ssZ"
    private static let apiDateWithoutTimeFormat    = "yyyy-MM-dd'T'Z"
    private static let hourAndMinuteDateTimeFormat = "HH:mm"
    private static let dayAndMonthDateTimeFormat   = "dd MMM"
    private static let dayMonthYearDateTimeFormat  = "dd.MM.yyyy"

    private static let apiFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = usedLocale
        dateFormatter.dateFormat = BaseDateFormatter.apiDateTimeFormat
        return dateFormatter
    }()

    private static let apiDateWithoutTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = usedLocale
        dateFormatter.dateFormat = BaseDateFormatter.apiDateWithoutTimeFormat
        return dateFormatter
    }()

    private static let hourAndMinuteFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.locale = usedLocale
        dateFormater.dateFormat = BaseDateFormatter.hourAndMinuteDateTimeFormat
        return dateFormater
    }()

    private static let dayAndMonthFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.locale = usedLocale
        dateFormater.dateFormat = BaseDateFormatter.dayAndMonthDateTimeFormat
        return dateFormater
    }()

    private static let dayMonthYearFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.locale = usedLocale
        dateFormater.dateFormat = BaseDateFormatter.dayMonthYearDateTimeFormat
        return dateFormater
    }()

    // MARK: Public interface

    open class var usedLocale: Locale {
        return .current
    }

    public static func backendDate(fromStrDate strDate: String) -> Date? {
        return BaseDateFormatter.apiFormatter.date(from: strDate)
    }

    public static func backendStrDate(withDate date: Date) -> String {
        return BaseDateFormatter.apiFormatter.string(from: date)
    }

    public static func backendDateWithoutTime(withDate date: Date) -> String {
        return BaseDateFormatter.apiDateWithoutTimeFormatter.string(from: date)
    }

    public static func hourAndMinuteStrDate(withDate date: Date) -> String {
        return BaseDateFormatter.hourAndMinuteFormatter.string(from: date)
    }

    public static func dayMonthYearStrDate(withDate date: Date) -> String {
        return BaseDateFormatter.dayMonthYearFormatter.string(from: date)
    }

    // MARK: - Transformers

    public static var transformFromStringToDate: TransformOf<Date, String> {
        return TransformOf<Date, String>(fromJSON: { (stringValue) -> Date? in
            if let stringValue = stringValue {
                return BaseDateFormatter.backendDate(fromStrDate: stringValue)
            } else {
                return nil
            }
        }, toJSON: { (dateValue) -> String? in
            if let dateValue = dateValue {
                return BaseDateFormatter.backendStrDate(withDate: dateValue)
            } else {
                return nil
            }
        })
    }

}
