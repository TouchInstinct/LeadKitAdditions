# Changelog

### 0.3.2

- **Add**: functions to `BasePassCodeViewController` to make `fakeTextField` become and resign first responder

### 0.3.1
- **Add**: `PinLayoutTableViewCell` and `SeparatorTableViewCell` to `Core-iOS-Extension`.

### 0.3.0
- **Remove**: `ApiResponse` class
- **Remove**: Occurrences of `ObjectMapper` in `BaseDateFormatter`
- **Remove**: `ApiError` enum and `ApiErrorProtocol`
- **Remove**: `Observable` extension related to error handling
- **Remove**: `ApiNetworkService`
- **Remove**: `DefaultNetworkService` and its extensions

### 0.2.9
- **Add**: `evaluatedPolicyDomainState` to `BiometricsService`.

### 0.2.8
- **Update**: `validationResult` of `BasePassCodeViewModel` renamed to `validationResultDriver` and becomes public.
- **Remove**: `MaskFieldTextProxy`.
- **Remove**: `InputMask` dependency
- **Replace**: `IDZSwiftCommonCrypto` with `CryptoSwift`

### 0.2.7

- **Fix**: Build with new LeadKit 0.7.9

### 0.2.6

- **Update**: `DefaultNetworkService` supported `NetworkServiceConfiguration`

### 0.2.5

- **Add**: Methods to notify when biometrics auth begins and ends.

### 0.2.4
- **Add**: `PinLayout` dependency.
- **Add**: `PinLayoutTableViewCell`, `SeparatorTableViewCell` and `LabelTableViewCell` powered by PinLayout.
- **Add**: `LabelCellViewModel` default view model for label cell.
- **Add**: Playground to project.

### 0.2.3
- **Update**: Xcode 9.3 migration.

### 0.2.2
- **Add**: `PassCodeDelayedDescription` to schedule error messages

### 0.2.1
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

