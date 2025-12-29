class ApiConfig {
  // TODO: Replace with your local network IP address
  // Find your IP:
  //   Windows: ipconfig
  //   Mac: ifconfig en0 | grep inet
  //   Linux: ip addr show
  // Example: http://192.168.1.100:8000
  static const String baseUrl = 'http://192.168.0.118:8000';

  // API Endpoints
  static const String completedOrdersEndpoint = '/api/orders/completed';
  static const String summaryEndpoint = '/api/orders/summary';

  // Configuration
  static const int timeoutSeconds = 15;
  static const int defaultDays = 30;
  static const bool defaultUseCache = true;

  // Full URLs
  static String get completedOrdersUrl => '$baseUrl$completedOrdersEndpoint';
  static String get summaryUrl => '$baseUrl$summaryEndpoint';

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
