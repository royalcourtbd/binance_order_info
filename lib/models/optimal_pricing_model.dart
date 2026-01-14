import 'transaction_item_model.dart';

/// Optimal Pricing Calculator Model
/// Calculates the required sell rate to achieve target profit per USDT
class OptimalPricingModel {
  // Buy transaction statistics
  final double totalBuyAmount; // Total BDT spent (including manual charges)
  final double totalBuyUsdt; // Total USDT received (after commission)
  final double avgBuyRate; // Average buy rate per USDT (BDT/USDT)
  final int buyTransactionCount; // Number of buy transactions
  final double averageFixedCharge; // Average fixed charge per buy transaction

  // Sell transaction statistics (for reference)
  final double totalSellAmount; // Total BDT received (including manual charges)
  final double totalSellUsdt; // Total USDT sold
  final double avgSellRate; // Average sell rate per USDT (BDT/USDT)
  final int sellTransactionCount; // Number of sell transactions

  // Profit calculation
  final double currentProfit; // Current profit in BDT
  final double currentProfitPerUsdt; // Current profit per USDT

  // Target profit calculation
  final double targetProfitPerUsdt; // Target profit per USDT (default: 1 BDT)
  final double
  requiredSellRate; // Required effective sell rate (after buyer bonus)
  final double binanceUnitPrice; // Binance এ set করার unit price
  final double effectiveSellRate; // Buyer bonus সহ actual rate

  // Binance fee structure (fixed values)
  static const double binanceFeeRate = 0.002; // 0.2% commission
  static const double buyerMarkupRate = 0.0180; // 1.80% extra buyer pays
  static const double fixedBuyCharge = 5.0; // Fixed 5 BDT per buy transaction

  OptimalPricingModel({
    required this.totalBuyAmount,
    required this.totalBuyUsdt,
    required this.avgBuyRate,
    required this.buyTransactionCount,
    required this.averageFixedCharge,
    required this.totalSellAmount,
    required this.totalSellUsdt,
    required this.avgSellRate,
    required this.sellTransactionCount,
    required this.currentProfit,
    required this.currentProfitPerUsdt,
    required this.targetProfitPerUsdt,
    required this.requiredSellRate,
    required this.binanceUnitPrice,
    required this.effectiveSellRate,
  });

  /// Factory constructor to create OptimalPricingModel from transaction list
  factory OptimalPricingModel.fromTransactions(
    List<TransactionItemModel> transactions, {
    double targetProfitPerUsdt = 1.0,
  }) {
    // Separate buy and sell transactions
    final buyTransactions = transactions
        .where((t) => t.category.toUpperCase() == 'BUY')
        .toList();
    final sellTransactions = transactions
        .where((t) => t.category.toUpperCase() == 'SELL')
        .toList();

    // Calculate buy statistics
    double totalBuyAmount = 0.0;
    double totalBuyUsdt = 0.0;
    for (var transaction in buyTransactions) {
      final amount = double.tryParse(transaction.totalPrice) ?? 0.0;
      final manualCharge = transaction.manualCharge ?? 0.0;
      totalBuyAmount += amount + manualCharge;

      // Get received USDT (after commission)
      final receivedUsdt =
          double.tryParse(transaction.getReceivedQuantity()) ?? 0.0;
      totalBuyUsdt += receivedUsdt;
    }

    final avgBuyRate = totalBuyUsdt > 0 ? totalBuyAmount / totalBuyUsdt : 0.0;
    final buyCount = buyTransactions.length;
    final avgFixedCharge = buyCount > 0 ? fixedBuyCharge : 0.0;

    // Calculate sell statistics
    double totalSellAmount = 0.0;
    double totalSellUsdt = 0.0;
    for (var transaction in sellTransactions) {
      final amount = double.tryParse(transaction.totalPrice) ?? 0.0;
      final manualCharge = transaction.manualCharge ?? 0.0;
      totalSellAmount += amount + manualCharge;

      // Get display USDT
      final displayUsdt =
          double.tryParse(transaction.getDisplayCryptoAmount()) ?? 0.0;
      totalSellUsdt += displayUsdt;
    }

    final avgSellRate = totalSellUsdt > 0
        ? totalSellAmount / totalSellUsdt
        : 0.0;
    final sellCount = sellTransactions.length;

    // Calculate current profit
    final currentProfit = (avgSellRate - avgBuyRate) * totalSellUsdt;
    final currentProfitPerUsdt = totalSellUsdt > 0
        ? currentProfit / totalSellUsdt
        : 0.0;

    // Calculate Binance unit price and effective sell rate
    //
    // Formula derivation:
    // When selling X USDT at unit price P:
    // - Wallet outflow: X × 1.002 USDT (including 0.2% commission)
    // - Income: X × P × 1.0180 BDT (including 1.80% buyer bonus)
    // - Cost: X × 1.002 × avgBuyRate BDT
    // - Profit: (X × P × 1.0180) - (X × 1.002 × avgBuyRate)
    // - Target: X × targetProfitPerUsdt
    //
    // Solving for P:
    // P × 1.0180 - 1.002 × avgBuyRate = targetProfitPerUsdt
    // P = (targetProfitPerUsdt + 1.002 × avgBuyRate) / 1.0180
    //
    final binanceUnitPrice = avgBuyRate > 0
        ? (targetProfitPerUsdt + (1.002 * avgBuyRate)) / 1.0180
        : 0.0;

    // Effective sell rate = what you actually receive per USDT from wallet
    // When selling X USDT: wallet outflow = X × 1.002, income = X × P × 1.0180
    // Effective rate = income / wallet outflow = (X × P × 1.0180) / (X × 1.002)
    //                = (P × 1.0180) / 1.002
    //                = (targetProfitPerUsdt + 1.002 × avgBuyRate) / 1.002
    final effectiveSellRate =
        (targetProfitPerUsdt + (1.002 * avgBuyRate)) / 1.002;

    // Required sell rate (kept for backward compatibility, same as effective)
    final requiredSellRate = effectiveSellRate;

    return OptimalPricingModel(
      totalBuyAmount: totalBuyAmount,
      totalBuyUsdt: totalBuyUsdt,
      avgBuyRate: avgBuyRate,
      buyTransactionCount: buyCount,
      averageFixedCharge: avgFixedCharge,
      totalSellAmount: totalSellAmount,
      totalSellUsdt: totalSellUsdt,
      avgSellRate: avgSellRate,
      sellTransactionCount: sellCount,
      currentProfit: currentProfit,
      currentProfitPerUsdt: currentProfitPerUsdt,
      targetProfitPerUsdt: targetProfitPerUsdt,
      requiredSellRate: requiredSellRate,
      binanceUnitPrice: binanceUnitPrice,
      effectiveSellRate: effectiveSellRate,
    );
  }

  /// Calculate required sell rate for a custom target profit
  double calculateRequiredSellRate(double targetProfit) {
    return avgBuyRate + targetProfit;
  }

  /// Calculate expected profit for a given sell rate
  double calculateExpectedProfit(double sellRate) {
    return sellRate - avgBuyRate;
  }

  /// Calculate total profit for a given quantity and sell rate
  double calculateTotalProfit(double quantity, double sellRate) {
    final profitPerUsdt = sellRate - avgBuyRate;
    return profitPerUsdt * quantity;
  }

  /// Get fee breakdown explanation
  Map<String, dynamic> getFeeBreakdown() {
    return {
      'binance_fee_percentage': '${(binanceFeeRate * 100).toStringAsFixed(2)}%',
      'buyer_markup_percentage':
          '${(buyerMarkupRate * 100).toStringAsFixed(2)}%',
      'fixed_buy_charge': '৳${fixedBuyCharge.toStringAsFixed(2)}',
      'average_fixed_charge_per_transaction':
          '৳${averageFixedCharge.toStringAsFixed(2)}',
    };
  }

  /// Copy with new target profit
  OptimalPricingModel copyWithTargetProfit(double newTargetProfit) {
    // Recalculate Binance unit price and effective rate
    final newBinanceUnitPrice = avgBuyRate > 0
        ? (newTargetProfit + (1.002 * avgBuyRate)) / 1.0180
        : 0.0;
    final newEffectiveSellRate =
        (newTargetProfit + (1.002 * avgBuyRate)) / 1.002;

    return OptimalPricingModel(
      totalBuyAmount: totalBuyAmount,
      totalBuyUsdt: totalBuyUsdt,
      avgBuyRate: avgBuyRate,
      buyTransactionCount: buyTransactionCount,
      averageFixedCharge: averageFixedCharge,
      totalSellAmount: totalSellAmount,
      totalSellUsdt: totalSellUsdt,
      avgSellRate: avgSellRate,
      sellTransactionCount: sellTransactionCount,
      currentProfit: currentProfit,
      currentProfitPerUsdt: currentProfitPerUsdt,
      targetProfitPerUsdt: newTargetProfit,
      requiredSellRate: newEffectiveSellRate,
      binanceUnitPrice: newBinanceUnitPrice,
      effectiveSellRate: newEffectiveSellRate,
    );
  }
}
