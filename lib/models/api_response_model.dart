class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? count;
  final bool? cached;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.count,
    this.cached,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      count: json['count'],
      cached: json['cached'],
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse<T>(
      success: false,
      message: message,
    );
  }
}

class SummaryResponse {
  final int totalBuyOrders;
  final int totalSellOrders;
  final int totalCompletedOrders;
  final double totalBuyAmount;
  final double totalSellAmount;
  final double totalBuyValue;
  final double totalSellValue;
  final double totalBuyFees;
  final double totalSellFees;
  final double totalFees;
  final double averageBuyPrice;
  final double averageSellPrice;
  final double netProfitBdt;
  final double netProfitPercentage;

  SummaryResponse({
    required this.totalBuyOrders,
    required this.totalSellOrders,
    required this.totalCompletedOrders,
    required this.totalBuyAmount,
    required this.totalSellAmount,
    required this.totalBuyValue,
    required this.totalSellValue,
    required this.totalBuyFees,
    required this.totalSellFees,
    required this.totalFees,
    required this.averageBuyPrice,
    required this.averageSellPrice,
    required this.netProfitBdt,
    required this.netProfitPercentage,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    return SummaryResponse(
      totalBuyOrders: json['total_buy_orders'] ?? 0,
      totalSellOrders: json['total_sell_orders'] ?? 0,
      totalCompletedOrders: json['total_completed_orders'] ?? 0,
      totalBuyAmount: (json['total_buy_amount'] ?? 0).toDouble(),
      totalSellAmount: (json['total_sell_amount'] ?? 0).toDouble(),
      totalBuyValue: (json['total_buy_value'] ?? 0).toDouble(),
      totalSellValue: (json['total_sell_value'] ?? 0).toDouble(),
      totalBuyFees: (json['total_buy_fees'] ?? 0).toDouble(),
      totalSellFees: (json['total_sell_fees'] ?? 0).toDouble(),
      totalFees: (json['total_fees'] ?? 0).toDouble(),
      averageBuyPrice: (json['average_buy_price'] ?? 0).toDouble(),
      averageSellPrice: (json['average_sell_price'] ?? 0).toDouble(),
      netProfitBdt: (json['net_profit_bdt'] ?? 0).toDouble(),
      netProfitPercentage: (json['net_profit_percentage'] ?? 0).toDouble(),
    );
  }

  factory SummaryResponse.empty() {
    return SummaryResponse(
      totalBuyOrders: 0,
      totalSellOrders: 0,
      totalCompletedOrders: 0,
      totalBuyAmount: 0.0,
      totalSellAmount: 0.0,
      totalBuyValue: 0.0,
      totalSellValue: 0.0,
      totalBuyFees: 0.0,
      totalSellFees: 0.0,
      totalFees: 0.0,
      averageBuyPrice: 0.0,
      averageSellPrice: 0.0,
      netProfitBdt: 0.0,
      netProfitPercentage: 0.0,
    );
  }
}
