# Changelog

## 0.2.2

- **Add**: `PassCodeDelayedDescription` to schedule error messages

## 0.2.1

- **Fixed**: BasePassCodeViewController doesn't draw last dot filled

## 0.2.0
- **Updated**: LeadKit to `0.7.x` version
- **Removed**: `CellField*` and `FormField*` protocols and classes.
- **Add**: `BaseTextFieldViewEvents` and `BaseTextFieldViewModelEvents` with default offline and online validation.
- **Deprecated**: `DefaultNetworkService`.

### 0.1.5
- **Update**: Passcode private configuration

### 0.1.4
- **Update**: Refactor PassCode

### 0.1.3
- **Update**: Typical api response keys naming

### 0.1.2
- **Update**: Access modifiers of `ValidationService`

### 0.1.1

- **Add**: `acceptableStatusCodes` property in `DefaultNetworkService`.
- **Add**: `retry(retryLimit:canRetryClosure:)` to `Observable` extension.
- **Removed**: `retryWithinErrors` method from `Observable` extension.
- **Update**: LeadKit to `0.6.x` version
- **Removed**: `ConnectionError`. (Replaced by `LeadKit.RequestError`)
- **Removed**: `handleConnectionErrors` from Observable+Extensions


## 0.1.0

- **Add**: support for Swift 3.2 / 4

