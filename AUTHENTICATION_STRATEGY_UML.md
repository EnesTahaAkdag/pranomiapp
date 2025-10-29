# Authentication Strategy Pattern - UML Diagrams

## Class Diagram

```
┌─────────────────────────────────────┐
│  <<interface>>                      │
│  IAuthenticationStrategy            │
├─────────────────────────────────────┤
│ + type: AuthenticationType          │
├─────────────────────────────────────┤
│ + execute(LoginResponseModel):      │
│   Future<AuthenticationResult>      │
│ + canHandle(LoginResponseModel):    │
│   bool                               │
└─────────────────────────────────────┘
              △
              │ implements
    ┌─────────┴─────────────────┐
    │                           │
┌───┴──────────────────┐  ┌─────┴──────────────────┐
│ DirectLoginStrategy  │  │ SmsVerificationStrategy│
├──────────────────────┤  ├────────────────────────┤
│ - _credentialStrategy│  │                        │
├──────────────────────┤  ├────────────────────────┤
│ + execute()          │  │ + execute()            │
│ + canHandle()        │  │ + canHandle()          │
│ + type: direct       │  │ + type: smsVerification│
└──────────────────────┘  └────────────────────────┘

    ┌──────────────────────────┐
    │ TwoFactorAuthStrategy    │
    ├──────────────────────────┤
    │                          │
    ├──────────────────────────┤
    │ + execute()              │
    │ + canHandle()            │
    │ + type: twoFactorAuth    │
    └──────────────────────────┘

┌──────────────────────────────────────┐
│ AuthenticationContext                │
├──────────────────────────────────────┤
│ - _strategies: List<IAuth...>        │
│ - _currentStrategy: IAuth...?        │
├──────────────────────────────────────┤
│ + selectStrategy(LoginResponse):     │
│   IAuthenticationStrategy            │
│ + authenticate(LoginResponse):       │
│   Future<AuthenticationResult>       │
│ + currentStrategy: IAuth...?         │
│ + currentType: AuthenticationType?   │
└──────────────────────────────────────┘
        │ uses
        ▼
┌──────────────────────────────────────┐
│ CredentialPersistenceStrategy        │
├──────────────────────────────────────┤
│                                      │
├──────────────────────────────────────┤
│ + saveCredentials(ApiInfoModel):     │
│   Future<bool>                       │
│ + clearCredentials(): Future<bool>   │
│ + hasStoredCredentials():            │
│   Future<bool>                       │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ AuthenticationResult                 │
├──────────────────────────────────────┤
│ + isSuccess: bool                    │
│ + errorMessage: String?              │
│ + nextAction: AuthenticationAction   │
│ + data: Map<String, dynamic>?        │
├──────────────────────────────────────┤
│ + success(): AuthenticationResult    │
│ + error(): AuthenticationResult      │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ <<enum>> AuthenticationAction        │
├──────────────────────────────────────┤
│ • navigateToHome                     │
│ • navigateToSmsVerification          │
│ • navigateToTwoFactorAuth            │
│ • showError                          │
│ • none                               │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ <<enum>> AuthenticationType          │
├──────────────────────────────────────┤
│ • direct                             │
│ • smsVerification                    │
│ • twoFactorAuth                      │
└──────────────────────────────────────┘
```

## Sequence Diagram: Direct Login Flow

```
User    LoginPage    LoginPageViewModel    AuthenticationContext    DirectLoginStrategy    CredentialPersistence
 │           │                │                      │                        │                     │
 │  Enter    │                │                      │                        │                     │
 │ Credentials│               │                      │                        │                     │
 ├──────────>│                │                      │                        │                     │
 │           │   login()      │                      │                        │                     │
 │           ├───────────────>│                      │                        │                     │
 │           │                │                      │                        │                     │
 │           │                │  API call            │                        │                     │
 │           │                ├─────────────────────>│                        │                     │
 │           │                │                      │                        │                     │
 │           │                │  LoginResponseModel  │                        │                     │
 │           │                │  (requireSms=false)  │                        │                     │
 │           │                │<─────────────────────│                        │                     │
 │           │                │                      │                        │                     │
 │           │                │  authenticate(item)  │                        │                     │
 │           │                ├─────────────────────>│                        │                     │
 │           │                │                      │                        │                     │
 │           │                │                      │  selectStrategy()      │                     │
 │           │                │                      │  - check canHandle()   │                     │
 │           │                │                      │    for each strategy   │                     │
 │           │                │                      ├───────────────────────>│                     │
 │           │                │                      │                        │                     │
 │           │                │                      │  execute(loginResponse)│                     │
 │           │                │                      ├───────────────────────>│                     │
 │           │                │                      │                        │                     │
 │           │                │                      │                        │  saveCredentials()  │
 │           │                │                      │                        ├────────────────────>│
 │           │                │                      │                        │                     │
 │           │                │                      │                        │  success (true)     │
 │           │                │                      │                        │<────────────────────│
 │           │                │                      │                        │                     │
 │           │                │                      │  AuthenticationResult  │                     │
 │           │                │                      │  (navigateToHome)      │                     │
 │           │                │                      │<───────────────────────│                     │
 │           │                │                      │                        │                     │
 │           │                │  AuthenticationResult│                        │                     │
 │           │                │<─────────────────────│                        │                     │
 │           │                │                      │                        │                     │
 │           │                │  Update state:       │                        │                     │
 │           │                │  _loginSuccessful=true│                       │                     │
 │           │                │  notifyListeners()   │                        │                     │
 │           │                │                      │                        │                     │
 │           │  State change  │                      │                        │                     │
 │           │<───────────────│                      │                        │                     │
 │           │                │                      │                        │                     │
 │  Navigate │                │                      │                        │                     │
 │  to Home  │                │                      │                        │                     │
 │<──────────│                │                      │                        │                     │
```

## Sequence Diagram: SMS Verification Flow

```
User    LoginPage    LoginPageViewModel    AuthenticationContext    SmsVerificationStrategy
 │           │                │                      │                        │
 │  Enter    │                │                      │                        │
 │ Credentials│               │                      │                        │
 ├──────────>│                │                      │                        │
 │           │   login()      │                      │                        │
 │           ├───────────────>│                      │                        │
 │           │                │                      │                        │
 │           │                │  API call            │                        │
 │           │                ├─────────────────────>│                        │
 │           │                │                      │                        │
 │           │                │  LoginResponseModel  │                        │
 │           │                │  (requireSms=true,   │                        │
 │           │                │   hasActive2FA=false)│                        │
 │           │                │<─────────────────────│                        │
 │           │                │                      │                        │
 │           │                │  authenticate(item)  │                        │
 │           │                ├─────────────────────>│                        │
 │           │                │                      │                        │
 │           │                │                      │  selectStrategy()      │
 │           │                │                      │  - TwoFactorAuth.      │
 │           │                │                      │    canHandle() → false │
 │           │                │                      │  - SmsVerification.    │
 │           │                │                      │    canHandle() → TRUE  │
 │           │                │                      ├───────────────────────>│
 │           │                │                      │                        │
 │           │                │                      │  execute(loginResponse)│
 │           │                │                      ├───────────────────────>│
 │           │                │                      │                        │
 │           │                │                      │  Validate userId       │
 │           │                │                      │  Validate gsmNumber    │
 │           │                │                      │                        │
 │           │                │                      │  AuthenticationResult  │
 │           │                │                      │  (navigateToSmsVerif)  │
 │           │                │                      │<───────────────────────│
 │           │                │                      │                        │
 │           │                │  AuthenticationResult│                        │
 │           │                │<─────────────────────│                        │
 │           │                │                      │                        │
 │           │                │  Update state:       │                        │
 │           │                │  _requiresSmsVerif=  │                        │
 │           │                │  true                │                        │
 │           │                │  notifyListeners()   │                        │
 │           │                │                      │                        │
 │           │  State change  │                      │                        │
 │           │<───────────────│                      │                        │
 │           │                │                      │                        │
 │  Navigate │                │                      │                        │
 │  to SMS   │                │                      │                        │
 │  Page     │                │                      │                        │
 │<──────────│                │                      │                        │
```

## Strategy Selection Decision Tree

```
                    LoginResponseModel received
                              │
                              ▼
                    ┌─────────────────┐
                    │ requireSms?     │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
            false                         true
              │                             │
              ▼                             ▼
    ┌─────────────────┐           ┌─────────────────┐
    │ DirectLogin     │           │ hasActive2FA?   │
    │ Strategy        │           └────────┬────────┘
    │                 │                    │
    │ - Save creds    │         ┌──────────┴──────────┐
    │ - Navigate home │         │                     │
    └─────────────────┘       true                  false
                                │                     │
                                ▼                     ▼
                    ┌─────────────────┐   ┌─────────────────┐
                    │ TwoFactorAuth   │   │ SmsVerification │
                    │ Strategy        │   │ Strategy        │
                    │                 │   │                 │
                    │ - Validate data │   │ - Validate data │
                    │ - Navigate to   │   │ - Navigate to   │
                    │   2FA page      │   │   SMS page      │
                    └─────────────────┘   └─────────────────┘
```

## Component Interaction Overview

```
┌────────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                          │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌──────────────┐          ┌─────────────────────────────┐        │
│  │  LoginPage   │ observes │  LoginPageViewModel         │        │
│  │              │◄─────────│                             │        │
│  │  - UI        │          │  - usernameController       │        │
│  │  - Form      │          │  - passwordController       │        │
│  │              │          │  - _authContext             │        │
│  └──────────────┘          │  - login()                  │        │
│                            └──────────────┬──────────────┘        │
│                                           │                        │
└───────────────────────────────────────────┼────────────────────────┘
                                            │ uses
                                            ▼
┌────────────────────────────────────────────────────────────────────┐
│                         Domain Layer                               │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌────────────────────────────────────────────────────┐            │
│  │        AuthenticationContext                       │            │
│  │                                                    │            │
│  │  Strategies:                                       │            │
│  │  1. TwoFactorAuthStrategy                          │            │
│  │  2. SmsVerificationStrategy                        │            │
│  │  3. DirectLoginStrategy                            │            │
│  │                                                    │            │
│  │  Methods:                                          │            │
│  │  - selectStrategy()                                │            │
│  │  - authenticate()                                  │            │
│  └────────────────┬───────────────────────────────────┘            │
│                   │                                                │
│                   │ manages                                        │
│                   ▼                                                │
│  ┌────────────────────────────────────────────────────┐            │
│  │         IAuthenticationStrategy                    │            │
│  │         (Interface)                                │            │
│  ├────────────────────────────────────────────────────┤            │
│  │  + execute(): Future<AuthenticationResult>         │            │
│  │  + canHandle(): bool                               │            │
│  │  + type: AuthenticationType                        │            │
│  └───┬──────────────────────────┬─────────────────┬───┘            │
│      │                          │                 │                │
│      ▼                          ▼                 ▼                │
│  ┌───────┐              ┌──────────┐      ┌──────────┐            │
│  │Direct │              │   SMS    │      │   2FA    │            │
│  │Login  │              │Verification     │  Auth    │            │
│  └───┬───┘              └──────────┘      └──────────┘            │
│      │                                                             │
│      │ uses                                                        │
│      ▼                                                             │
│  ┌─────────────────────────────┐                                  │
│  │ CredentialPersistence       │                                  │
│  │ Strategy                    │                                  │
│  │                             │                                  │
│  │ - saveCredentials()         │                                  │
│  │ - clearCredentials()        │                                  │
│  └─────────────────────────────┘                                  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
                                            │
                                            │ returns
                                            ▼
                              ┌───────────────────────┐
                              │ AuthenticationResult  │
                              ├───────────────────────┤
                              │ - isSuccess           │
                              │ - errorMessage        │
                              │ - nextAction          │
                              │ - data                │
                              └───────────────────────┘
```

## File Structure Tree

```
lib/
├── features/
│   └── authentication/
│       ├── data/
│       │   └── login_services.dart          # API service
│       ├── domain/
│       │   ├── authentication_strategy.dart  # Interface & result classes
│       │   ├── authentication_context.dart   # Strategy manager
│       │   ├── credential_persistence_strategy.dart
│       │   └── strategies/
│       │       ├── direct_login_strategy.dart
│       │       ├── sms_verification_strategy.dart
│       │       └── two_factor_auth_strategy.dart
│       └── presentation/
│           ├── login_page_view_model.dart   # Uses AuthenticationContext
│           └── login_page.dart               # UI
└── core/
    └── di/
        └── injection.dart                    # Dependency injection setup
```

## Strategy Pattern Benefits Visualization

```
┌────────────────────────────────────────────────────────────┐
│                    WITHOUT Strategy Pattern                │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  LoginPageViewModel                                        │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  if (!requireSms) {                                  │ │
│  │    if (apiInfo != null) {                            │ │
│  │      // Save credentials manually                    │ │
│  │      final prefs = await SharedPreferences...        │ │
│  │      await prefs.setString('apiKey', ...)            │ │
│  │      await prefs.setString('apiSecret', ...)         │ │
│  │      await prefs.setString('subscriptionType', ...)  │ │
│  │      _loginSuccessful = true                         │ │
│  │    }                                                  │ │
│  │  } else {                                             │ │
│  │    if (hasActive2FA) {                                │ │
│  │      _requiresTwoFactorAuth = true                   │ │
│  │    } else {                                           │ │
│  │      _requiresSmsVerification = true                 │ │
│  │    }                                                  │ │
│  │  }                                                    │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                            │
│  Issues:                                                   │
│  ❌ Tight coupling                                         │
│  ❌ Duplicated credential saving code (3 places)           │
│  ❌ Hard to test                                           │
│  ❌ Hard to add new auth methods                           │
│  ❌ Violates Open/Closed Principle                         │
│                                                            │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                     WITH Strategy Pattern                  │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  LoginPageViewModel                                        │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  final authResult = await _authContext.authenticate( │ │
│  │    item                                               │ │
│  │  );                                                   │ │
│  │                                                       │ │
│  │  switch (authResult.nextAction) {                    │ │
│  │    case AuthenticationAction.navigateToHome:         │ │
│  │      _loginSuccessful = true;                        │ │
│  │      break;                                           │ │
│  │    case AuthenticationAction.navigateToSmsVerif:     │ │
│  │      _requiresSmsVerification = true;                │ │
│  │      break;                                           │ │
│  │    case AuthenticationAction.navigateToTwoFactor:    │ │
│  │      _requiresTwoFactorAuth = true;                  │ │
│  │      break;                                           │ │
│  │  }                                                    │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                            │
│  Benefits:                                                 │
│  ✅ Loose coupling                                         │
│  ✅ No code duplication                                    │
│  ✅ Easy to test each strategy                             │
│  ✅ Easy to add new strategies                             │
│  ✅ Follows Open/Closed Principle                          │
│  ✅ Single Responsibility Principle                        │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Testing Strategy Visualization

```
┌──────────────────────────────────────────────────────────┐
│                Unit Tests (Isolated)                     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  DirectLoginStrategy Tests                               │
│  ┌────────────────────────────────────────────────────┐ │
│  │ ✓ Saves credentials correctly                      │ │
│  │ ✓ Returns navigateToHome action                    │ │
│  │ ✓ Handles missing apiInfo                          │ │
│  │ ✓ canHandle returns true when requireSms=false     │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  SmsVerificationStrategy Tests                           │
│  ┌────────────────────────────────────────────────────┐ │
│  │ ✓ Returns navigateToSmsVerification action         │ │
│  │ ✓ Validates userId correctly                       │ │
│  │ ✓ Validates gsmNumber correctly                    │ │
│  │ ✓ canHandle checks requireSms && !hasActive2FA     │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  TwoFactorAuthStrategy Tests                             │
│  ┌────────────────────────────────────────────────────┐ │
│  │ ✓ Returns navigateToTwoFactorAuth action           │ │
│  │ ✓ Validates userId correctly                       │ │
│  │ ✓ Validates gsmNumber correctly                    │ │
│  │ ✓ canHandle checks requireSms && hasActive2FA      │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│               Integration Tests                          │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  AuthenticationContext Tests                             │
│  ┌────────────────────────────────────────────────────┐ │
│  │ ✓ Selects DirectLogin when requireSms=false        │ │
│  │ ✓ Selects SmsVerif when requireSms && !2FA         │ │
│  │ ✓ Selects 2FA when requireSms && hasActive2FA      │ │
│  │ ✓ Falls back to DirectLogin when no match          │ │
│  │ ✓ authenticate() executes selected strategy        │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                 Widget Tests                             │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  LoginPageViewModel Tests                                │
│  ┌────────────────────────────────────────────────────┐ │
│  │ ✓ Updates state based on AuthenticationResult      │ │
│  │ ✓ Sets _loginSuccessful on navigateToHome          │ │
│  │ ✓ Sets _requiresSmsVerif on navigateToSmsVerif     │ │
│  │ ✓ Sets _requiresTwoFactorAuth on navigateTo2FA     │ │
│  │ ✓ Shows error message on authentication failure    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```
