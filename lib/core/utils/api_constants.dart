/// Centralized API constants for the Pranomi app
/// This file contains all API-related URLs, endpoints, headers, and configuration
class ApiConstants {
  ApiConstants._();

  // ============================================================================
  // BASE URLS
  // ============================================================================

  /// Test/Development API base URL
  static const String baseUrlTest = 'https://apitest.pranomi.com/';

  /// Production API base URL
  static const String baseUrlProduction = 'https://api.pranomi.com/';

  /// Currently active base URL (change this to switch environments)
  static const String baseUrl = baseUrlTest;

  // ============================================================================
  // ENDPOINT PATHS
  // ============================================================================

  // Customer endpoints
  /// Customer list/search endpoint
  static const String customerEndpoint = 'customer';

  /// Customer list endpoint
  static const String customerListEndpoint = 'customer/list';

  // Invoice endpoints
  /// Invoice endpoint
  static const String invoiceEndpoint = 'invoice';

  /// Invoice list endpoint
  static const String invoiceListEndpoint = 'invoice/list';

  // Product endpoints
  /// Product endpoint
  static const String productEndpoint = 'product';

  /// Product list endpoint
  static const String productListEndpoint = 'product/list';

  // E-Invoice endpoints
  /// E-invoice endpoint
  static const String eInvoiceEndpoint = 'e_invoice';

  /// E-invoice list endpoint
  static const String eInvoiceListEndpoint = 'e_invoice/list';

  // Authentication endpoints
  /// Login endpoint
  static const String loginEndpoint = 'auth/login';

  /// Logout endpoint
  static const String logoutEndpoint = 'auth/logout';

  /// Token refresh endpoint
  static const String refreshTokenEndpoint = 'auth/refresh';

  // Employee endpoints
  /// Employee endpoint
  static const String employeeEndpoint = 'employee';

  /// Employee list endpoint
  static const String employeeListEndpoint = 'employee/list';

  // Credit endpoints
  /// Credit endpoint
  static const String creditEndpoint = 'credit';

  /// Credit list endpoint
  static const String creditListEndpoint = 'credit/list';

  // Dashboard endpoints
  /// Dashboard statistics endpoint
  static const String dashboardEndpoint = 'dashboard';

  // Notification endpoints
  /// Notifications endpoint
  static const String notificationsEndpoint = 'notifications';

  /// Notifications list endpoint
  static const String notificationsListEndpoint = 'notifications/list';

  // Announcement endpoints
  /// Announcements endpoint
  static const String announcementsEndpoint = 'announcements';

  // ============================================================================
  // HTTP HEADERS
  // ============================================================================

  /// Content-Type header for JSON
  static const String contentTypeJson = 'application/json';

  /// Content-Type header for form data
  static const String contentTypeFormData = 'application/x-www-form-urlencoded';

  /// Content-Type header for multipart
  static const String contentTypeMultipart = 'multipart/form-data';

  /// Accept header for JSON
  static const String acceptJson = 'application/json';

  // Header keys
  /// API Key header name
  static const String headerApiKey = 'ApiKey';

  /// API Secret header name
  static const String headerApiSecret = 'ApiSecret';

  /// Authorization header name
  static const String headerAuthorization = 'Authorization';

  /// Content-Type header name
  static const String headerContentType = 'Content-Type';

  /// Accept header name
  static const String headerAccept = 'Accept';

  // ============================================================================
  // HTTP STATUS CODES
  // ============================================================================

  /// Success status code
  static const int statusCodeSuccess = 200;

  /// Created status code
  static const int statusCodeCreated = 201;

  /// Bad request status code
  static const int statusCodeBadRequest = 400;

  /// Unauthorized status code
  static const int statusCodeUnauthorized = 401;

  /// Forbidden status code
  static const int statusCodeForbidden = 403;

  /// Not found status code
  static const int statusCodeNotFound = 404;

  /// Internal server error status code
  static const int statusCodeServerError = 500;

  // ============================================================================
  // TIMEOUT CONFIGURATION
  // ============================================================================

  /// Default connection timeout in seconds
  static const int connectionTimeoutSeconds = 10;

  /// Default receive timeout in seconds
  static const int receiveTimeoutSeconds = 10;

  /// Default send timeout in seconds
  static const int sendTimeoutSeconds = 10;

  // ============================================================================
  // EXTERNAL URLS
  // ============================================================================

  /// Panel base URL for e-commerce logos
  static const String panelBaseUrl = 'https://panel.pranomi.com/';

  /// E-commerce logo path
  static String eCommerceLogoUrl(String eCommerceCode) =>
      '${panelBaseUrl}images/ecommerceLogo/$eCommerceCode.png';

  /// E-invoice URL with UUID
  static String eInvoiceUrl(String uuid) =>
      '${panelBaseUrl}e_invoice/geteinvoices?uuids=$uuid';

  // ============================================================================
  // SHARED PREFERENCES KEYS
  // ============================================================================

  /// API Key storage key
  static const String prefApiKey = 'apiKey';

  /// API Secret storage key
  static const String prefApiSecret = 'apiSecret';

  /// Auth token storage key
  static const String prefAuthToken = 'authToken';

  /// Subscription type storage key
  static const String prefSubscriptionType = 'subscriptionType';

  /// User email storage key
  static const String prefUserEmail = 'userEmail';
}
