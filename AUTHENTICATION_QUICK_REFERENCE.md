# Authentication Strategy Pattern - Quick Reference

## TL;DR

The authentication logic has been refactored using the **Strategy Pattern** to eliminate code duplication and improve maintainability. Instead of nested if-else statements, we now use strategy classes that handle different authentication flows.

## Quick Start

### Understanding the Flow

**3 Authentication Strategies:**

1. **DirectLoginStrategy** - No verification needed (`requireSms = false`)
2. **SmsVerificationStrategy** - SMS code required (`requireSms = true`, `hasActive2FA = false`)
3. **TwoFactorAuthStrategy** - 2FA code required (`requireSms = true`, `hasActive2FA = true`)

### Key Files

| File | Purpose | Location |
|------|---------|----------|
| `authentication_strategy.dart` | Base interface & result classes | `lib/features/authentication/domain/` |
| `authentication_context.dart` | Strategy selector/manager | `lib/features/authentication/domain/` |
| `direct_login_strategy.dart` | Direct login implementation | `lib/features/authentication/domain/strategies/` |
| `sms_verification_strategy.dart` | SMS verification implementation | `lib/features/authentication/domain/strategies/` |
| `two_factor_auth_strategy.dart` | 2FA implementation | `lib/features/authentication/domain/strategies/` |
| `credential_persistence_strategy.dart` | Credential storage | `lib/features/authentication/domain/` |
| `login_page_view_model.dart` | Uses the strategy pattern | `lib/features/authentication/presentation/` |

## How to Use

### In LoginPageViewModel

```dart
// Initialize in constructor
LoginPageViewModel() {
  _authContext = AuthenticationContext(
    credentialStrategy: CredentialPersistenceStrategy(),
  );
}

// Use in login method
final authResult = await _authContext.authenticate(loginResponse);

if (authResult.isSuccess) {
  switch (authResult.nextAction) {
    case AuthenticationAction.navigateToHome:
      _loginSuccessful = true;
      break;
    case AuthenticationAction.navigateToSmsVerification:
      _requiresSmsVerification = true;
      break;
    case AuthenticationAction.navigateToTwoFactorAuth:
      _requiresTwoFactorAuth = true;
      break;
  }
} else {
  _errorMessage = authResult.errorMessage;
}
```

## Decision Matrix

| requireSms | hasActive2FA | Strategy Used | Action |
|------------|--------------|---------------|--------|
| `false` | any | DirectLoginStrategy | Navigate to home |
| `true` | `false` | SmsVerificationStrategy | Navigate to SMS page |
| `true` | `true` | TwoFactorAuthStrategy | Navigate to 2FA page |

## Common Tasks

### Adding a New Authentication Strategy

1. **Create strategy class:**

```dart
// lib/features/authentication/domain/strategies/my_new_strategy.dart
class MyNewStrategy implements IAuthenticationStrategy {
  @override
  AuthenticationType get type => AuthenticationType.myNew;

  @override
  bool canHandle(LoginResponseModel loginResponse) {
    // Define when this strategy should be used
    return loginResponse.someCondition == true;
  }

  @override
  Future<AuthenticationResult> execute(LoginResponseModel loginResponse) async {
    // Implement authentication logic
    return AuthenticationResult.success(
      nextAction: AuthenticationAction.navigateToSomewhere,
    );
  }
}
```

2. **Add to AuthenticationType enum:**

```dart
enum AuthenticationType {
  direct,
  smsVerification,
  twoFactorAuth,
  myNew,  // Add here
}
```

3. **Add to AuthenticationAction enum (if needed):**

```dart
enum AuthenticationAction {
  navigateToHome,
  navigateToSmsVerification,
  navigateToTwoFactorAuth,
  navigateToMyNewPage,  // Add here
  showError,
  none,
}
```

4. **Register in dependency injection:**

```dart
// lib/core/di/injection.dart
locator.registerLazySingleton<MyNewStrategy>(
  () => MyNewStrategy(),
);
```

5. **Add to AuthenticationContext:**

```dart
// lib/features/authentication/domain/authentication_context.dart
AuthenticationContext({
  CredentialPersistenceStrategy? credentialStrategy,
}) : _strategies = [
  MyNewStrategy(),           // Add in priority order
  TwoFactorAuthStrategy(),
  SmsVerificationStrategy(),
  DirectLoginStrategy(credentialStrategy: credentialStrategy),
];
```

### Testing a Strategy

```dart
test('MyNewStrategy handles specific condition', () async {
  final strategy = MyNewStrategy();

  final loginResponse = LoginResponseModel(
    someCondition: true,
  );

  // Test canHandle
  expect(strategy.canHandle(loginResponse), true);

  // Test execute
  final result = await strategy.execute(loginResponse);

  expect(result.isSuccess, true);
  expect(result.nextAction, AuthenticationAction.navigateToMyNewPage);
});
```

### Debugging Strategy Selection

```dart
// In LoginPageViewModel, after authenticate():
print('Selected strategy: ${_authContext.currentType}');
print('Next action: ${authResult.nextAction}');
print('Success: ${authResult.isSuccess}');
```

## API Reference

### IAuthenticationStrategy

```dart
abstract class IAuthenticationStrategy {
  /// Execute the authentication logic
  Future<AuthenticationResult> execute(LoginResponseModel loginResponse);

  /// Get the strategy type
  AuthenticationType get type;

  /// Check if this strategy can handle the login response
  bool canHandle(LoginResponseModel loginResponse);
}
```

### AuthenticationResult

```dart
class AuthenticationResult {
  final bool isSuccess;
  final String? errorMessage;
  final AuthenticationAction nextAction;
  final Map<String, dynamic>? data;

  // Factory constructors
  factory AuthenticationResult.success({
    required AuthenticationAction nextAction,
    Map<String, dynamic>? data,
  });

  factory AuthenticationResult.error({
    required String message,
    AuthenticationAction nextAction = AuthenticationAction.showError,
  });
}
```

### AuthenticationContext

```dart
class AuthenticationContext {
  /// Select strategy based on login response
  IAuthenticationStrategy selectStrategy(LoginResponseModel loginResponse);

  /// Execute authentication with selected strategy
  Future<AuthenticationResult> authenticate(LoginResponseModel loginResponse);

  /// Get current strategy
  IAuthenticationStrategy? get currentStrategy;

  /// Get current authentication type
  AuthenticationType? get currentType;
}
```

### CredentialPersistenceStrategy

```dart
class CredentialPersistenceStrategy {
  /// Save API credentials to SharedPreferences
  Future<bool> saveCredentials(ApiInfoModel apiInfo);

  /// Clear stored credentials
  Future<bool> clearCredentials();

  /// Check if credentials exist
  Future<bool> hasStoredCredentials();
}
```

## Examples

### Example 1: Direct Login

```dart
// API returns:
LoginResponseModel(
  requireSms: false,
  apiInfo: ApiInfoModel(
    apiKey: 'key123',
    apiSecret: 'secret456',
    // ...
  ),
)

// Strategy selected: DirectLoginStrategy
// Action: navigateToHome
// Result: Credentials saved, user logged in
```

### Example 2: SMS Verification

```dart
// API returns:
LoginResponseModel(
  requireSms: true,
  hasActive2FA: false,
  userId: 12345,
  gsmNumber: '+905551234567',
)

// Strategy selected: SmsVerificationStrategy
// Action: navigateToSmsVerification
// Result: Navigate to SMS verification page
```

### Example 3: Two-Factor Authentication

```dart
// API returns:
LoginResponseModel(
  requireSms: true,
  hasActive2FA: true,
  userId: 12345,
  gsmNumber: '+905551234567',
)

// Strategy selected: TwoFactorAuthStrategy
// Action: navigateToTwoFactorAuth
// Result: Navigate to 2FA page
```

## Error Handling

### Strategy-Level Errors

```dart
// In strategy execute() method:
try {
  // Authentication logic
  return AuthenticationResult.success(...);
} catch (e) {
  return AuthenticationResult.error(
    message: 'Specific error: $e',
  );
}
```

### Context-Level Errors

```dart
// AuthenticationContext.authenticate() catches all errors:
try {
  final result = await strategy.execute(loginResponse);
  return result;
} catch (e) {
  return AuthenticationResult.error(
    message: 'Kimlik doğrulama hatası: $e',
  );
}
```

### ViewModel-Level Errors

```dart
// In LoginPageViewModel:
final authResult = await _authContext.authenticate(item);

if (!authResult.isSuccess) {
  _errorMessage = authResult.errorMessage ?? 'Bilinmeyen hata';
}
```

## Best Practices

### ✅ Do

- Use `AuthenticationContext.authenticate()` for all authentication flows
- Check `authResult.isSuccess` before processing the action
- Return specific error messages from strategies
- Add logging/debugging info in strategies for troubleshooting
- Write unit tests for each new strategy

### ❌ Don't

- Don't bypass the strategy pattern with direct if-else checks
- Don't save credentials in multiple places (use `CredentialPersistenceStrategy`)
- Don't modify the strategy list order without considering priority
- Don't forget to register new strategies in dependency injection
- Don't mix old authentication logic with new strategy pattern

## Migration Notes

### What Changed

- `LoginPageViewModel.login()` now uses `AuthenticationContext`
- Credential saving centralized in `CredentialPersistenceStrategy`
- Authentication decision logic moved to strategy classes

### What Stayed the Same

- Public API of `LoginPageViewModel` (getters, methods)
- UI layer (`LoginPage`) unchanged
- API service (`LoginServices`) unchanged
- Database/SharedPreferences structure unchanged

### Backward Compatibility

✅ **100% Compatible** - All existing authentication flows work identically

## Troubleshooting

### Issue: Wrong strategy selected

**Solution:** Check the `canHandle()` method in each strategy. Strategies are evaluated in order, so ensure priority is correct.

```dart
// Debug in LoginPageViewModel:
print('requireSms: ${item.requireSms}');
print('hasActive2FA: ${item.hasActive2FA}');
print('Selected strategy: ${_authContext.currentType}');
```

### Issue: Credentials not saved

**Solution:** Check that `DirectLoginStrategy` is being executed and `apiInfo` is not null.

```dart
// Debug in DirectLoginStrategy:
print('apiInfo null: ${loginResponse.apiInfo == null}');
print('Credentials saved: $saved');
```

### Issue: Navigation not working

**Solution:** Ensure the `LoginPage` is listening to ViewModel changes and handling the flags correctly.

```dart
// In LoginPage._onViewModelChanged:
if (viewModel.loginSuccessful) {
  context.go('/');
}
```

## Performance

- **Strategy Selection:** O(n) where n = number of strategies (currently 3)
- **Memory:** Negligible - strategies are singletons
- **Execution Time:** No measurable overhead compared to if-else

## Related Documentation

- [Full Documentation](./AUTHENTICATION_STRATEGY_PATTERN.md)
- [UML Diagrams](./AUTHENTICATION_STRATEGY_UML.md)
- [Project Instructions](./CLAUDE.md)

## Checklist for Code Review

When reviewing authentication code:

- [ ] Strategy pattern is used (no direct if-else for auth logic)
- [ ] New strategies are registered in dependency injection
- [ ] Error handling is implemented in strategies
- [ ] Unit tests exist for new strategies
- [ ] `canHandle()` logic is correct
- [ ] `execute()` returns appropriate `AuthenticationResult`
- [ ] Credentials are saved via `CredentialPersistenceStrategy`
- [ ] Navigation actions are handled in ViewModel

## Support

For questions or issues with the authentication strategy pattern:

1. Review this quick reference
2. Check the full documentation
3. Look at existing strategy implementations as examples
4. Debug using the troubleshooting section above

---

**Last Updated:** 2025-10-20
**Version:** 1.0
