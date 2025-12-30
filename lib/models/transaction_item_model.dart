class TransactionItemModel {
  final String category;
  final String title;
  final String method;
  final String amount; // Deprecated: use totalPrice instead (kept for backward compatibility)
  final String totalPrice; // Total fiat price (e.g., 5000.00 BDT)
  final String? cryptoAmount; // Crypto amount (e.g., 39.64 USDT)
  final int? createTime;
  final String? orderStatus;
  final String? unitPrice;
  final String? asset;
  final String? fiat;
  final String? fiatSymbol;
  final String? advNo;
  final String? commission;
  final String? counterPartNickName;
  final bool? additionalKycVerify;

  TransactionItemModel({
    required this.category,
    required this.title,
    required this.method,
    required this.amount,
    required this.totalPrice,
    this.cryptoAmount,
    this.createTime,
    this.orderStatus,
    this.unitPrice,
    this.asset,
    this.fiat,
    this.fiatSymbol,
    this.advNo,
    this.commission,
    this.counterPartNickName,
    this.additionalKycVerify,
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

    final totalPriceValue = json['totalPrice']?.toString() ?? '0.00';

    return TransactionItemModel(
      category: json['tradeType'] ?? 'UNKNOWN',
      title: '#${json['orderNumber'] ?? ''}',
      method: json['payMethodName'] ?? json['payType'] ?? '',
      amount: totalPriceValue, // For backward compatibility
      totalPrice: totalPriceValue,
      cryptoAmount: json['amount']?.toString(),
      createTime: createTime,
      orderStatus: json['orderStatus'],
      unitPrice: json['unitPrice']?.toString(),
      asset: json['asset'],
      fiat: json['fiat'],
      fiatSymbol: json['fiatSymbol'],
      advNo: json['advNo']?.toString(),
      commission: json['commission']?.toString(),
      counterPartNickName: json['counterPartNickName'],
      additionalKycVerify: json['additionalKycVerify'],
    );
  }
}
