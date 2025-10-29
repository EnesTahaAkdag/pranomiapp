# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pranomi is a Flutter business management application for handling invoices, customers, e-invoices, products, and accounting. It's built using Flutter 3.7.2+ and targets multiple platforms (Android, iOS, macOS, Web).

## Development Commands

### Setup and Dependencies
```bash
# Install dependencies
flutter pub get

# Generate launcher icons
flutter pub run flutter_launcher_icons:main

# Generate splash screens
flutter pub run flutter_native_splash:create
```

### Running the Application
```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release

# List available devices
flutter devices
```

### Building
```bash
# Build for Android (APK)
flutter build apk

# Build for Android (App Bundle)
flutter build appbundle

# Build for iOS
flutter build ios

# Build for macOS
flutter build macos

# Build for web
flutter build web
```

### Code Quality
```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/
```

## Architecture

### High-Level Structure

The codebase follows a **hybrid architecture** combining:
- **Feature-based modules** (newer code) - organized by business domain
- **Traditional layer separation** (legacy code) - Pages, Models, Services

### Feature Module Pattern (Preferred for New Code)

```
lib/features/
  ├── [feature_name]/
  │   ├── data/           # API services, data models
  │   ├── domain/         # Business models, enums
  │   └── presentation/   # Views, ViewModels, State classes
```

**Key Features Using This Pattern:**
- `authentication/` - Login and auth management
- `credit/` - Credit transactions with MVVM + Provider pattern
- `dashboard/` - Main dashboard with statistics
- `announcement/` - System announcements
- `e_invoice/` - E-invoice and e-dispatch management
- `notifications/` - User notifications
- `products/` - Product and service management
- `employees/` - Employee management

### Legacy Structure

```
lib/
  ├── Pages/              # UI pages (older code)
  ├── Models/             # Data models (older code)
  ├── services/           # API services (older code)
  └── Helper/             # Utility classes
```

### Core Infrastructure

```
lib/core/
  ├── di/                 # Dependency injection (GetIt)
  ├── router/             # Navigation (GoRouter)
  ├── services/           # Core services (AuthService)
  ├── theme/              # AppTheme with centralized colors
  └── widgets/            # Shared UI components
```

## Key Architectural Patterns

### 1. Dependency Injection with GetIt

All services are registered in `lib/core/di/injection.dart`. When creating new services:

```dart
// In injection.dart
locator.registerLazySingleton<YourService>(() => YourService());

// Usage in widgets
final service = locator<YourService>();
```

### 2. State Management

The app uses **two state management approaches**:

**A. Provider Pattern (MVVM) - Preferred for New Features**
- ViewModel extends `ChangeNotifier`
- State classes represent different states (Initial, Loading, Loaded, Error)
- Example: `lib/features/credit/` demonstrates this pattern perfectly

**B. StatefulWidget with Service Layer - Legacy**
- Direct service calls from widget State classes
- Manual state management with `setState()`
- Example: `lib/Pages/CustomersPages/CustomerPage/customer_page.dart`

### 3. Navigation with GoRouter

- Router configuration: `lib/core/router/app_router.dart`
- Uses ShellRoute for pages with AppLayout (drawer + bottom nav)
- Route titles mapped in `lib/core/router/route_titles.dart`
- Authentication-aware routing (redirects to login if not authenticated)

### 4. API Communication

**Base Service Pattern:**
- All API services extend `ApiServiceBase` (in `lib/core/services/api_service_base.dart`)
- Base URL: `https://apitest.pranomi.com/`
- Authentication: Basic Auth with API key/secret stored in SharedPreferences
- HTTP client: Dio with 10s timeout

**API Path Convention:**
- Customer endpoints: `customer/*` (no leading slash)
- Invoice endpoints: `invoice/*`
- Product endpoints: `product/*`

### 5. Theming

All colors and theme configuration are centralized in `lib/core/theme/app_theme.dart`:
- Primary color: Dark Gray (#3D3D3D)
- Accent color: Cranberry Red (#B00034)
- Use `AppTheme.primaryColor`, `AppTheme.accentColor`, etc.
- Never hardcode colors - always use AppTheme constants

## Common Patterns and Conventions

### Pagination
Most list pages use scroll-based pagination:
- Page size: typically 20 items
- Listen to ScrollController, load more at 200px from bottom
- Track `currentPage`, `totalPages`, `isLoading` states

### Search Implementation
- Use `CustomSearchBar` widget from `lib/core/widgets/custom_search_bar.dart`
- On search submit, reset pagination (`page = 0`) and fetch with search query
- Clear search: reset search text and re-fetch

### Turkish Localization
- App is Turkish-language focused
- Date formatting: Turkish locale (`tr_TR`)
- Currency: Turkish Lira (₺) with `NumberFormat.currency(locale: 'tr_TR')`

### Navigation After CRUD Operations
Pages should return navigation results:
```dart
// After successful save/delete:
context.pop('refresh');

// Calling page:
final result = await context.push('/SomePage');
if (result == 'refresh') {
  _fetchData(reset: true);
}
```

### Authentication Flow
1. On app start, check `AuthService.isLoggedIn()`
2. Store API credentials in SharedPreferences (`apiKey`, `apiSecret`)
3. Router redirects to `/login` if not authenticated
4. Subscription type affects menu visibility (stored in SharedPreferences)

## Important Implementation Notes

### When Creating New Features

1. **Follow the feature module pattern** (`lib/features/[feature_name]/`)
2. **Use MVVM with Provider** for state management
3. **Register services in GetIt** (`lib/core/di/injection.dart`)
4. **Add routes to GoRouter** (`lib/core/router/app_router.dart`)
5. **Use AppTheme constants** for all colors
6. **Extend ApiServiceBase** for API services

### Common Gotchas

- **Route paths**: Customer API paths should NOT have leading slashes (e.g., `customer/list` not `/customer/list`)
- **Authentication**: All API calls need auth headers via `getAuthHeaders()`
- **Mounted check**: Always check `if (mounted)` before `setState()` after async operations
- **Pagination**: Increment `currentPage + 1` for next page requests (API is 0-indexed)
- **Error handling**: Services return `null` on errors, check for null before using results

### Code Style

- Use descriptive variable names (Turkish text is acceptable for UI strings)
- Comment complex business logic in English
- Format code with `dart format` before committing
- Follow existing patterns when modifying legacy code

## Platform-Specific Notes

### Android
- App icon config: `android/app/src/main/res/`
- Adaptive icon background: #a10c35
- Splash screen color: #a10c35

### iOS/macOS
- Pod dependencies managed via Podfile
- Run `pod install` in ios/ or macos/ directories when adding plugins

### Assets
- Images: `lib/assets/images/`
- Icons: `lib/assets/icons/`
- JSON data: `lib/assets/json/` (countries, cities, districts for address forms)