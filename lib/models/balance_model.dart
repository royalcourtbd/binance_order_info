class AssetBalance {
  final String asset;
  final String free;
  final String locked;
  final String withdrawing;
  final String btcValuation;
  final double total;

  AssetBalance({
    required this.asset,
    required this.free,
    required this.locked,
    required this.withdrawing,
    required this.btcValuation,
    required this.total,
  });

  factory AssetBalance.fromJson(Map<String, dynamic> json) {
    return AssetBalance(
      asset: json['asset'] ?? '',
      free: json['free'] ?? '0',
      locked: json['locked'] ?? '0',
      withdrawing: json['withdrawing'] ?? '0',
      btcValuation: json['btcValuation'] ?? '0',
      total: (json['total'] is num) ? (json['total'] as num).toDouble() : 0.0,
    );
  }
}

class TopAsset {
  final String asset;
  final double total;
  final String btcValuation;

  TopAsset({
    required this.asset,
    required this.total,
    required this.btcValuation,
  });

  factory TopAsset.fromJson(Map<String, dynamic> json) {
    return TopAsset(
      asset: json['asset'] ?? '',
      total: (json['total'] is num) ? (json['total'] as num).toDouble() : 0.0,
      btcValuation: json['btcValuation'] ?? '0',
    );
  }
}

class BalanceSummary {
  final int totalAssets;
  final int spotAssets;
  final int fundingAssets;
  final double totalBtcValuation;
  final double usdtBalance;
  final List<TopAsset> topAssets;

  BalanceSummary({
    required this.totalAssets,
    required this.spotAssets,
    required this.fundingAssets,
    required this.totalBtcValuation,
    required this.usdtBalance,
    required this.topAssets,
  });

  factory BalanceSummary.fromJson(Map<String, dynamic> json) {
    return BalanceSummary(
      totalAssets: json['total_assets'] ?? 0,
      spotAssets: json['spot_assets'] ?? 0,
      fundingAssets: json['funding_assets'] ?? 0,
      totalBtcValuation: (json['total_btc_valuation'] is num)
          ? (json['total_btc_valuation'] as num).toDouble()
          : 0.0,
      usdtBalance: (json['usdt_balance'] is num)
          ? (json['usdt_balance'] as num).toDouble()
          : 0.0,
      topAssets:
          (json['top_assets'] as List?)
              ?.map((e) => TopAsset.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BalanceData {
  final List<AssetBalance> spotWallet;
  final List<AssetBalance> fundingWallet;

  BalanceData({required this.spotWallet, required this.fundingWallet});

  factory BalanceData.fromJson(Map<String, dynamic> json) {
    return BalanceData(
      spotWallet:
          (json['spot_wallet'] as List?)
              ?.map((e) => AssetBalance.fromJson(e))
              .toList() ??
          [],
      fundingWallet:
          (json['funding_wallet'] as List?)
              ?.map((e) => AssetBalance.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BalanceResponse {
  final bool success;
  final String message;
  final BalanceData data;
  final BalanceSummary summary;
  final bool? cached;

  BalanceResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.summary,
    this.cached,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: BalanceData.fromJson(json['data'] ?? {}),
      summary: BalanceSummary.fromJson(json['summary'] ?? {}),
      cached: json['cached'],
    );
  }

  factory BalanceResponse.empty() {
    return BalanceResponse(
      success: false,
      message: '',
      data: BalanceData(spotWallet: [], fundingWallet: []),
      summary: BalanceSummary(
        totalAssets: 0,
        spotAssets: 0,
        fundingAssets: 0,
        totalBtcValuation: 0.0,
        usdtBalance: 0.0,
        topAssets: [],
      ),
      cached: false,
    );
  }
}
