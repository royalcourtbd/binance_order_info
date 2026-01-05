import 'package:intl/intl.dart';
import 'transaction_item_model.dart';

class DateSectionModel {
  final String date;
  final String day;
  final String year;
  final String dayBuy; // Total buy without manual charges
  final String daySell; // Total sell without manual charges
  final String dayBuyWithCharge; // Total buy with manual charges
  final String daySellWithCharge; // Total sell with manual charges
  final String dayBuyUsdt; // Total buy USDT for the day
  final String daySellUsdt; // Total sell USDT for the day
  final String avgBuyRate; // Average actual buy rate for the day
  final String avgSellRate; // Average actual sell rate for the day
  final List<TransactionItemModel> transactions;

  DateSectionModel({
    required this.date,
    required this.day,
    required this.year,
    required this.dayBuy,
    required this.daySell,
    required this.dayBuyWithCharge,
    required this.daySellWithCharge,
    required this.dayBuyUsdt,
    required this.daySellUsdt,
    required this.avgBuyRate,
    required this.avgSellRate,
    required this.transactions,
  });

  factory DateSectionModel.fromTransactions(
    DateTime dateTime,
    List<TransactionItemModel> transactions,
  ) {
    // Calculate daily buy and sell totals (with and without manual charges)
    double totalBuy = 0.0;
    double totalSell = 0.0;
    double totalBuyWithCharge = 0.0;
    double totalSellWithCharge = 0.0;

    // Calculate weighted average rates (total BDT / total USDT)
    double totalBuyBdt = 0.0;
    double totalBuyUsdt = 0.0;
    double totalSellBdt = 0.0;
    double totalSellUsdt = 0.0;

    for (var transaction in transactions) {
      final amount = double.tryParse(transaction.amount) ?? 0.0;
      final manualCharge = transaction.manualCharge ?? 0.0;

      if (transaction.category.toUpperCase() == 'BUY') {
        totalBuy += amount;
        totalBuyWithCharge += amount + manualCharge;
        // For weighted average: accumulate total BDT and total USDT
        totalBuyBdt += amount + manualCharge;
        // Get the USDT amount for BUY (received quantity after commission)
        final receivedUsdt =
            double.tryParse(transaction.getReceivedQuantity()) ?? 0.0;
        totalBuyUsdt += receivedUsdt;
      } else if (transaction.category.toUpperCase() == 'SELL') {
        totalSell += amount;
        totalSellWithCharge += amount + manualCharge;
        // For weighted average: accumulate total BDT and total USDT
        totalSellBdt += amount + manualCharge;
        // Get the USDT amount for SELL (display crypto amount)
        final displayUsdt =
            double.tryParse(transaction.getDisplayCryptoAmount()) ?? 0.0;
        totalSellUsdt += displayUsdt;
      }
    }

    // Calculate weighted average rates
    final avgBuyRate = totalBuyUsdt > 0 ? totalBuyBdt / totalBuyUsdt : 0.0;
    final avgSellRate = totalSellUsdt > 0 ? totalSellBdt / totalSellUsdt : 0.0;

    return DateSectionModel(
      date: DateFormat('dd').format(dateTime),
      day: DateFormat('EEE').format(dateTime),
      year: DateFormat('MM.yyyy').format(dateTime),
      dayBuy: totalBuy.toStringAsFixed(2),
      daySell: totalSell.toStringAsFixed(2),
      dayBuyWithCharge: totalBuyWithCharge.toStringAsFixed(2),
      daySellWithCharge: totalSellWithCharge.toStringAsFixed(2),
      dayBuyUsdt: totalBuyUsdt.toStringAsFixed(2),
      daySellUsdt: totalSellUsdt.toStringAsFixed(2),
      avgBuyRate: avgBuyRate.toStringAsFixed(2),
      avgSellRate: avgSellRate.toStringAsFixed(2),
      transactions: transactions,
    );
  }
}
