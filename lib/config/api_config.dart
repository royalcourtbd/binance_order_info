class ApiConfig {
  // Base URL for the Binance P2P API
  static const String baseUrl = 'https://binance-p2p-api-snowy.vercel.app';

  // API Endpoints
  static const String completedOrdersEndpoint = '/api/orders/completed';
  static const String summaryEndpoint = '/api/orders/summary';
  static const String balanceEndpoint = '/api/orders/balance/all';

  // Configuration
  static const int timeoutSeconds = 15;
  static const int defaultDays = 30;
  static const bool defaultUseCache = true;

  // Get base URL
  static String getBaseUrl() {
    return baseUrl;
  }

  // Full URLs
  static String getCompletedOrdersUrl() {
    return '$baseUrl$completedOrdersEndpoint';
  }

  static String getSummaryUrl() {
    return '$baseUrl$summaryEndpoint';
  }

  // Build URL with query parameters
  static String buildUrl(
    String endpoint, {
    int days = defaultDays,
    bool useCache = defaultUseCache,
  }) {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: {
        'days': days.toString(),
        'use_cache': useCache.toString(),
      },
    );
    return uri.toString();
  }
}
