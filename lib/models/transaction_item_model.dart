class TransactionItemModel {
  final String category;
  final String title;
  final String method;
  final String amount;
  final int? createTime;
  final String? orderStatus;
  final String? unitPrice;
  final String? asset;
  final String? fiat;

  TransactionItemModel({
    required this.category,
    required this.title,
    required this.method,
    required this.amount,
    this.createTime,
    this.orderStatus,
    this.unitPrice,
    this.asset,
    this.fiat,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    // Safely parse createTime - handle different types
    int? createTime;
    final createTimeValue = json['createTime'];
    if (createTimeValue is int) {
      createTime = createTimeValue;
    } else if (createTimeValue is String) {
      createTime = int.tryParse(createTimeValue);
    } else if (createTimeValue is Map) {
      // Try to extract timestamp from map if it exists
      if (createTimeValue.containsKey('timestamp')) {
        createTime = createTimeValue['timestamp'] as int?;
      } else if (createTimeValue.containsKey('value')) {
        createTime = createTimeValue['value'] as int?;
      }
    }

    return TransactionItemModel(
      category: json['tradeType'] ?? 'UNKNOWN',
      title: '#${json['orderNumber'] ?? ''}',
      method: json['payMethodName'] ?? json['payType'] ?? '',
      amount: json['totalPrice']?.toString() ?? '0.00',
      createTime: createTime,
      orderStatus: json['orderStatus'],
      unitPrice: json['unitPrice']?.toString(),
      asset: json['asset'],
      fiat: json['fiat'],
    );
  }
}
