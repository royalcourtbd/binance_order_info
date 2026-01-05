import 'package:intl/intl.dart';
import 'date_section_model.dart';

class MonthSectionModel {
  final String monthName; // "January 2026"
  final String month; // "01"
  final String year; // "2026"
  final String monthBuy; // Total buy BDT for the month without manual charges
  final String monthSell; // Total sell BDT for the month without manual charges
  final String monthBuyWithCharge; // Total buy BDT with manual charges
  final String monthSellWithCharge; // Total sell BDT with manual charges
  final String monthBuyUsdt; // Total buy USDT for the month
  final String monthSellUsdt; // Total sell USDT for the month
  final String avgBuyRate; // Average actual buy rate for the month
  final String avgSellRate; // Average actual sell rate for the month
  final String profitTk; // Profit in BDT for the month
  final String profitBuyRate; // Buy rate used for profit calc
  final String profitSellRate; // Sell rate used for profit calc
  final bool
  usedPreviousBuyRate; // True when profit buy rate uses previous month
  final List<DateSectionModel> dateSections;

  MonthSectionModel({
    required this.monthName,
    required this.month,
    required this.year,
    required this.monthBuy,
    required this.monthSell,
    required this.monthBuyWithCharge,
    required this.monthSellWithCharge,
    required this.monthBuyUsdt,
    required this.monthSellUsdt,
    required this.avgBuyRate,
    required this.avgSellRate,
    required this.profitTk,
    required this.profitBuyRate,
    required this.profitSellRate,
    required this.usedPreviousBuyRate,
    required this.dateSections,
  });

  factory MonthSectionModel.fromDateSections(
    DateTime monthDate,
    List<DateSectionModel> dateSections,
  ) {
    // Calculate monthly buy and sell totals (with and without manual charges)
    double totalBuy = 0.0;
    double totalSell = 0.0;
    double totalBuyWithCharge = 0.0;
    double totalSellWithCharge = 0.0;
    double totalBuyUsdt = 0.0;
    double totalSellUsdt = 0.0;

    // Calculate weighted average rates (total BDT / total USDT)
    double totalBuyBdt = 0.0;
    double totalSellBdt = 0.0;

    for (var dateSection in dateSections) {
      totalBuy += double.tryParse(dateSection.dayBuy) ?? 0.0;
      totalSell += double.tryParse(dateSection.daySell) ?? 0.0;
      totalBuyWithCharge +=
          double.tryParse(dateSection.dayBuyWithCharge) ?? 0.0;
      totalSellWithCharge +=
          double.tryParse(dateSection.daySellWithCharge) ?? 0.0;

      // Calculate USDT totals and weighted BDT totals from transactions
      for (var transaction in dateSection.transactions) {
        final amount = double.tryParse(transaction.amount) ?? 0.0;
        final manualCharge = transaction.manualCharge ?? 0.0;

        if (transaction.category.toUpperCase() == 'BUY') {
          // For BUY: use received quantity (after commission)
          final receivedUsdt =
              double.tryParse(transaction.getReceivedQuantity()) ?? 0.0;
          totalBuyUsdt += receivedUsdt;
          totalBuyBdt += amount + manualCharge;
        } else if (transaction.category.toUpperCase() == 'SELL') {
          // For SELL: use display crypto amount
          final displayUsdt =
              double.tryParse(transaction.getDisplayCryptoAmount()) ?? 0.0;
          totalSellUsdt += displayUsdt;
          totalSellBdt += amount + manualCharge;
        }
      }
    }

    // Calculate weighted average rates
    final avgBuyRate = totalBuyUsdt > 0 ? totalBuyBdt / totalBuyUsdt : 0.0;
    final avgSellRate = totalSellUsdt > 0 ? totalSellBdt / totalSellUsdt : 0.0;

    final profit = (avgSellRate - avgBuyRate) * totalSellUsdt;

    return MonthSectionModel(
      monthName: DateFormat('MMMM yyyy').format(monthDate),
      month: DateFormat('MM').format(monthDate),
      year: DateFormat('yyyy').format(monthDate),
      monthBuy: totalBuy.toStringAsFixed(2),
      monthSell: totalSell.toStringAsFixed(2),
      monthBuyWithCharge: totalBuyWithCharge.toStringAsFixed(2),
      monthSellWithCharge: totalSellWithCharge.toStringAsFixed(2),
      monthBuyUsdt: totalBuyUsdt.toStringAsFixed(2),
      monthSellUsdt: totalSellUsdt.toStringAsFixed(2),
      avgBuyRate: avgBuyRate.toStringAsFixed(2),
      avgSellRate: avgSellRate.toStringAsFixed(2),
      profitTk: profit.toStringAsFixed(2),
      profitBuyRate: avgBuyRate.toStringAsFixed(2),
      profitSellRate: avgSellRate.toStringAsFixed(2),
      usedPreviousBuyRate: false,
      dateSections: dateSections,
    );
  }

  MonthSectionModel copyWith({
    String? profitTk,
    String? profitBuyRate,
    String? profitSellRate,
    bool? usedPreviousBuyRate,
  }) {
    return MonthSectionModel(
      monthName: monthName,
      month: month,
      year: year,
      monthBuy: monthBuy,
      monthSell: monthSell,
      monthBuyWithCharge: monthBuyWithCharge,
      monthSellWithCharge: monthSellWithCharge,
      monthBuyUsdt: monthBuyUsdt,
      monthSellUsdt: monthSellUsdt,
      avgBuyRate: avgBuyRate,
      avgSellRate: avgSellRate,
      profitTk: profitTk ?? this.profitTk,
      profitBuyRate: profitBuyRate ?? this.profitBuyRate,
      profitSellRate: profitSellRate ?? this.profitSellRate,
      usedPreviousBuyRate: usedPreviousBuyRate ?? this.usedPreviousBuyRate,
      dateSections: dateSections,
    );
  }
}
