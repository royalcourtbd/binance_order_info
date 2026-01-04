import 'package:intl/intl.dart';
import 'date_section_model.dart';

class MonthSectionModel {
  final String monthName; // "January 2026"
  final String month; // "01"
  final String year; // "2026"
  final String monthBuy; // Total buy for the month without manual charges
  final String monthSell; // Total sell for the month without manual charges
  final String monthBuyWithCharge; // Total buy with manual charges
  final String monthSellWithCharge; // Total sell with manual charges
  final List<DateSectionModel> dateSections;

  MonthSectionModel({
    required this.monthName,
    required this.month,
    required this.year,
    required this.monthBuy,
    required this.monthSell,
    required this.monthBuyWithCharge,
    required this.monthSellWithCharge,
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

    for (var dateSection in dateSections) {
      totalBuy += double.tryParse(dateSection.dayBuy) ?? 0.0;
      totalSell += double.tryParse(dateSection.daySell) ?? 0.0;
      totalBuyWithCharge += double.tryParse(dateSection.dayBuyWithCharge) ?? 0.0;
      totalSellWithCharge += double.tryParse(dateSection.daySellWithCharge) ?? 0.0;
    }

    return MonthSectionModel(
      monthName: DateFormat('MMMM yyyy').format(monthDate),
      month: DateFormat('MM').format(monthDate),
      year: DateFormat('yyyy').format(monthDate),
      monthBuy: totalBuy.toStringAsFixed(2),
      monthSell: totalSell.toStringAsFixed(2),
      monthBuyWithCharge: totalBuyWithCharge.toStringAsFixed(2),
      monthSellWithCharge: totalSellWithCharge.toStringAsFixed(2),
      dateSections: dateSections,
    );
  }
}
