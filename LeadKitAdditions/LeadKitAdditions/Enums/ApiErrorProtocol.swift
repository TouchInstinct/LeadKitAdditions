//
//  ApiErrorProtocol.swift
//  LeadKitAdditions
//
//  Created by Alexey Gerasimov on 27/04/2017.
//  Copyright © 2017 TouchInstinct. All rights reserved.
//

public protocol ApiErrorProtocol: RawRepresentable {}

extension Error {

    public func isApiError<T: ApiErrorProtocol>(_ apiErrorType: T) -> Bool where T.RawValue == Int {
        if let error = self as? ApiError,
            case let .error(code: code, message: _) = error,
            code == apiErrorType.rawValue {
            return true
        } else {
            return false
        }
    }

}
