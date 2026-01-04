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
  final double? manualCharge; // Manual charge in BDT (extra cost for BUY, extra income for SELL)
  final double actualRate; // Actual dollar rate including manual charge

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
    this.manualCharge,
    required this.actualRate,
  });

  /// Returns the display crypto amount based on transaction type
  /// BUY: Shows received amount (cryptoAmount - commission)
  /// SELL: Shows total deducted amount (cryptoAmount + commission)
  String getDisplayCryptoAmount() {
    if (cryptoAmount == null) return '0.00';

    final crypto = double.tryParse(cryptoAmount!) ?? 0.0;
    final fee = double.tryParse(commission ?? '0') ?? 0.0;

    if (category.toUpperCase() == 'BUY') {
      // For BUY: Show received amount (what user actually gets)
      return (crypto - fee).toStringAsFixed(2);
    } else {
      // For SELL: Show total deducted (what's taken from wallet)
      return (crypto + fee).toStringAsFixed(2);
    }
  }

  /// Returns the received quantity for BUY transactions
  String getReceivedQuantity() {
    if (cryptoAmount == null) return '0.00';
    final crypto = double.tryParse(cryptoAmount!) ?? 0.0;
    final fee = double.tryParse(commission ?? '0') ?? 0.0;
    return (crypto - fee).toStringAsFixed(2);
  }

  /// Returns the total quantity (base amount without commission calculation)
  String getTotalQuantity() {
    if (cryptoAmount == null) return '0.00';
    return double.tryParse(cryptoAmount!)?.toStringAsFixed(2) ?? cryptoAmount!;
  }

  /// Calculate actual dollar rate based on transaction type
  /// BUY: (Total BDT + Manual Charge) / Receive Quantity
  /// SELL: (Total BDT + Manual Charge) / Total Quantity
  static double calculateActualRate({
    required String category,
    required String totalPrice,
    required String? cryptoAmount,
    required String? commission,
    double? manualCharge,
  }) {
    final totalBdt = double.tryParse(totalPrice) ?? 0.0;
    final charge = manualCharge ?? 0.0;
    final totalWithCharge = totalBdt + charge;

    if (cryptoAmount == null || cryptoAmount == '0' || cryptoAmount.isEmpty) {
      return 0.0;
    }

    final crypto = double.tryParse(cryptoAmount) ?? 0.0;
    final fee = double.tryParse(commission ?? '0') ?? 0.0;

    if (category.toUpperCase() == 'BUY') {
      // BUY: Use received quantity (crypto - fee)
      final receiveQuantity = crypto - fee;
      if (receiveQuantity == 0) return 0.0;
      return totalWithCharge / receiveQuantity;
    } else {
      // SELL: Use total quantity (crypto + fee for deducted amount)
      // But based on screenshots, it seems total quantity is just crypto
      final totalQuantity = crypto + fee;
      if (totalQuantity == 0) return 0.0;
      return totalWithCharge / totalQuantity;
    }
  }

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

    // Parse manual charge if provided
    double? manualCharge;
    if (json['manualCharge'] != null) {
      manualCharge = (json['manualCharge'] as num).toDouble();
    }

    // Calculate actual rate
    final category = json['tradeType'] ?? 'UNKNOWN';
    final cryptoAmount = json['amount']?.toString();
    final commission = json['commission']?.toString();
    final actualRate = calculateActualRate(
      category: category,
      totalPrice: totalPriceValue,
      cryptoAmount: cryptoAmount,
      commission: commission,
      manualCharge: manualCharge,
    );

    return TransactionItemModel(
      category: category,
      title: '#${json['orderNumber'] ?? ''}',
      method: json['payMethodName'] ?? json['payType'] ?? '',
      amount: totalPriceValue, // For backward compatibility
      totalPrice: totalPriceValue,
      cryptoAmount: cryptoAmount,
      createTime: createTime,
      orderStatus: json['orderStatus'],
      unitPrice: json['unitPrice']?.toString(),
      asset: json['asset'],
      fiat: json['fiat'],
      fiatSymbol: json['fiatSymbol'],
      advNo: json['advNo']?.toString(),
      commission: commission,
      counterPartNickName: json['counterPartNickName'],
      additionalKycVerify: json['additionalKycVerify'],
      manualCharge: manualCharge,
      actualRate: actualRate,
    );
  }
}
