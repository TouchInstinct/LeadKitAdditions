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

import Foundation
import ObjectMapper

/// Base date formatter class, contains most frequently used formats, including RFC3339
open class BaseDateFormatter {

    private static let apiDateTimeFormat           = "yyyy-MM-dd'T'HH:mm:ssZ"
    private static let apiDateWithoutTimeFormat    = "yyyy-MM-dd'T'Z"
    private static let hourAndMinuteDateTimeFormat = "HH:mm"
    private static let dayAndMonthDateTimeFormat   = "dd MMM"
    private static let dayMonthYearDateTimeFormat  = "dd.MM.yyyy"

    private static let apiFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = apiDateTimeFormat
        return dateFormatter
    }()

    private static let apiDateWithoutTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = apiDateWithoutTimeFormat
        return dateFormatter
    }()

    private static let hourAndMinuteFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = hourAndMinuteDateTimeFormat
        return dateFormater
    }()

    private static let dayAndMonthFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = dayAndMonthDateTimeFormat
        return dateFormater
    }()

    private static let dayMonthYearFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = dayMonthYearDateTimeFormat
        return dateFormater
    }()

    // MARK: - Public interface

    /// DateFormatter's locale can be overriden
    open class var usedLocale: Locale {
        return .current
    }

    /// Parse date from string with format: yyyy-MM-dd'T'HH:mm:ssZ
    public static func backendDate(fromStrDate strDate: String) -> Date? {
        apiFormatter.locale = usedLocale
        return apiFormatter.date(from: strDate)
    }

    /// Serialize date into string with format: yyyy-MM-dd'T'HH:mm:ssZ
    public static func backendStrDate(withDate date: Date) -> String {
        apiFormatter.locale = usedLocale
        return apiFormatter.string(from: date)
    }

    /// Serialize date into string with format: yyyy-MM-dd'T'Z
    public static func backendDateWithoutTime(withDate date: Date) -> String {
        apiDateWithoutTimeFormatter.locale = usedLocale
        return apiDateWithoutTimeFormatter.string(from: date)
    }

    /// Serialize date into string with format: HH:mm
    public static func hourAndMinuteStrDate(withDate date: Date) -> String {
        hourAndMinuteFormatter.locale = usedLocale
        return hourAndMinuteFormatter.string(from: date)
    }

    /// Serialize date into string with format: dd MMM
    public static func dayAndMonthStrDate(withDate date: Date) -> String {
        hourAndMinuteFormatter.locale = usedLocale
        return dayAndMonthFormatter.string(from: date)
    }

    /// Serialize date into string with format: dd.MM.yyyy
    public static func dayMonthYearStrDate(withDate date: Date) -> String {
        hourAndMinuteFormatter.locale = usedLocale
        return dayMonthYearFormatter.string(from: date)
    }

    // MARK: - Transformers

    /// Transformer to workaround with dates in Mappable (ObjectMapper) objects
    public static var transformFromStringToDate: TransformOf<Date, String> {
        return TransformOf<Date, String>(fromJSON: { (stringValue) -> Date? in
            if let stringValue = stringValue {
                return backendDate(fromStrDate: stringValue)
            } else {
                return nil
            }
        }, toJSON: { (dateValue) -> String? in
            if let dateValue = dateValue {
                return backendStrDate(withDate: dateValue)
            } else {
                return nil
            }
        })
    }

}
