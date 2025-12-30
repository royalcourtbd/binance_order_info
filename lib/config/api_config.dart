import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _ipKey = 'server_ip_address';
  static const String _defaultIp = '192.168.0.101';
  static const String _port = '8000';

  // API Endpoints
  static const String completedOrdersEndpoint = '/api/orders/completed';
  static const String summaryEndpoint = '/api/orders/summary';

  // Configuration
  static const int timeoutSeconds = 15;
  static const int defaultDays = 30;
  static const bool defaultUseCache = true;

  // Get current IP address from SharedPreferences
  static Future<String> getIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipKey) ?? _defaultIp;
  }

  // Save IP address to SharedPreferences
  static Future<void> setIpAddress(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
  }

  // Get base URL with current IP
  static Future<String> getBaseUrl() async {
    final ip = await getIpAddress();
    return 'http://$ip:$_port';
  }

  // Full URLs
  static Future<String> getCompletedOrdersUrl() async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl$completedOrdersEndpoint';
  }

  static Future<String> getSummaryUrl() async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl$summaryEndpoint';
  }

  // Build URL with query parameters
  static Future<String> buildUrl(
    String endpoint, {
    int days = defaultDays,
    bool useCache = defaultUseCache,
  }) async {
    final baseUrl = await getBaseUrl();
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: {
        'days': days.toString(),
        'use_cache': useCache.toString(),
      },
    );
    return uri.toString();
  }
}
