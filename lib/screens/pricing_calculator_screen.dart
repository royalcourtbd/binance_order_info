import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/pricing_calculator_controller.dart';
import '../models/optimal_pricing_model.dart';

class PricingCalculatorScreen extends StatelessWidget {
  PricingCalculatorScreen({super.key});

  final PricingCalculatorController controller = Get.put(
    PricingCalculatorController(),
  );
  final TextEditingController targetProfitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Optimal Price Calculator',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isCalculating.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final model = controller.pricingModel.value;
        if (model == null) {
          return const Center(
            child: Text(
              'কোনো transaction data পাওয়া যায়নি',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.calculatePricing();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month selector
                _buildMonthSelector(context),
                const SizedBox(height: 20),

                // Current Statistics Card
                _buildStatisticsCard(model),
                const SizedBox(height: 20),

                // Target Profit Input
                _buildTargetProfitInput(context, model),
                const SizedBox(height: 20),

                // Required Sell Rate Result
                _buildRequiredSellRateCard(model),
                const SizedBox(height: 20),

                // Fee Breakdown
                _buildFeeBreakdown(),
                const SizedBox(height: 20),

                // Profit Scenarios
                _buildProfitScenariosTable(model),
                const SizedBox(height: 20),

                // Explanation Card
                _buildExplanationCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final months = controller.getAvailableMonths();
    if (months.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'মাস নির্বাচন করুন',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final selectedMonth = controller.selectedMonth.value.isEmpty
                  ? controller.getCurrentMonthName()
                  : controller.selectedMonth.value;

              return DropdownButton<String>(
                value: selectedMonth,
                isExpanded: true,
                items: months.map((month) {
                  return DropdownMenuItem(value: month, child: Text(month));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectMonth(value);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(OptimalPricingModel model) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'বর্তমান পরিসংখ্যান',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 24),
            _buildStatRow(
              'মোট Buy করা USDT',
              '${model.totalBuyUsdt.toStringAsFixed(2)} USDT',
              Colors.blue,
              Icons.arrow_downward,
            ),
            _buildStatRow(
              'মোট Buy এ খরচ',
              '৳${model.totalBuyAmount.toStringAsFixed(2)}',
              Colors.blue,
              Icons.payments,
            ),
            _buildStatRow(
              'Buy লেনদেন সংখ্যা',
              '${model.buyTransactionCount} টি',
              Colors.blue,
              Icons.shopping_cart,
            ),
            _buildStatRow(
              'গড় Buy রেট',
              '৳${model.avgBuyRate.toStringAsFixed(2)} / USDT',
              Colors.blue.shade700,
              Icons.trending_down,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'মোট Sell করা USDT',
              '${model.totalSellUsdt.toStringAsFixed(2)} USDT',
              Colors.red,
              Icons.arrow_upward,
            ),
            _buildStatRow(
              'মোট Sell থেকে আয়',
              '৳${model.totalSellAmount.toStringAsFixed(2)}',
              Colors.red,
              Icons.account_balance_wallet,
            ),
            _buildStatRow(
              'Sell লেনদেন সংখ্যা',
              '${model.sellTransactionCount} টি',
              Colors.red,
              Icons.sell,
            ),
            _buildStatRow(
              'বর্তমান গড় Sell রেট',
              '৳${model.avgSellRate.toStringAsFixed(2)} / USDT',
              Colors.red.shade700,
              Icons.trending_up,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'বর্তমান মোট লাভ',
              '৳${model.currentProfit.toStringAsFixed(2)}',
              model.currentProfit >= 0 ? Colors.green : Colors.red.shade900,
              model.currentProfit >= 0 ? Icons.celebration : Icons.warning,
            ),
            _buildStatRow(
              'প্রতি USDT এ বর্তমান লাভ',
              '৳${model.currentProfitPerUsdt.toStringAsFixed(2)}',
              model.currentProfitPerUsdt >= 0
                  ? Colors.green.shade700
                  : Colors.red.shade900,
              Icons.monetization_on,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetProfitInput(
    BuildContext context,
    OptimalPricingModel model,
  ) {
    targetProfitController.text = controller.targetProfit.value.toStringAsFixed(
      2,
    );

    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Text(
                  'টার্গেট লাভ সেট করুন',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'প্রতি USDT এ কত টাকা লাভ করতে চান?',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: targetProfitController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'লাভ (BDT)',
                      hintText: '1.00',
                      prefixText: '৳ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final value =
                        double.tryParse(targetProfitController.text) ?? 1.0;
                    controller.updateTargetProfit(value);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'হিসাব করুন',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quick preset buttons
            Wrap(
              spacing: 8,
              children: [0.50, 1.00, 1.50, 2.00, 3.00].map((profit) {
                return Obx(() {
                  final isSelected =
                      (controller.targetProfit.value - profit).abs() < 0.01;
                  return ActionChip(
                    label: Text('৳${profit.toStringAsFixed(2)}'),
                    backgroundColor: isSelected
                        ? Colors.amber.shade700
                        : Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onPressed: () {
                      controller.updateTargetProfit(profit);
                      targetProfitController.text = profit.toStringAsFixed(2);
                    },
                  );
                });
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredSellRateCard(OptimalPricingModel model) {
    final profitPercentage = model.avgBuyRate > 0
        ? (model.targetProfitPerUsdt / model.avgBuyRate) * 100
        : 0.0;

    return Card(
      elevation: 3,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stars, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Binance Unit Price',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'আপনি Binance এ এই price set করবেন',
              style: TextStyle(fontSize: 13, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Main Binance Unit Price Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade700, width: 3),
              ),
              child: Column(
                children: [
                  const Text(
                    '🎯 Binance এ Unit Price সেট করুন',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '৳${model.binanceUnitPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    'প্রতি USDT',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  // Divider
                  Divider(color: Colors.green.shade300, thickness: 1),
                  const SizedBox(height: 12),
                  // Effective rate explanation
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Buyer 1.80% extra দেবে',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'আপনি actually পাবেন',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳${model.effectiveSellRate.toStringAsFixed(2)} per USDT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Profit badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.celebration,
                          size: 16,
                          color: Colors.green.shade900,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'লাভ: ৳${model.targetProfitPerUsdt.toStringAsFixed(2)} (${profitPercentage.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Example calculation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calculate,
                        size: 18,
                        color: Colors.amber.shade900,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'উদাহরণ হিসাব',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'যদি আপনি 100 USDT sell করেন ৳${model.binanceUnitPrice.toStringAsFixed(2)} rate এ:',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalculationRow(
                          '• Wallet থেকে যাবে',
                          '100.20 USDT',
                          Colors.red.shade700,
                        ),
                        _buildCalculationRow(
                          '• আপনি পাবেন',
                          '৳${model.effectiveSellRate.toStringAsFixed(2)} × 100',
                          Colors.blue.shade700,
                        ),
                        const Divider(height: 16),
                        _buildCalculationRow(
                          '✓ মোট লাভ',
                          '৳${(model.targetProfitPerUsdt * 100).toStringAsFixed(2)}',
                          Colors.green.shade900,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.black87)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Binance ফি বিস্তারিত',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildFeeRow(
              'Buy করার সময় Binance commission',
              '0.20%',
              Colors.blue,
            ),
            _buildFeeRow(
              'Buy করার সময় আনুমানিক fixed charge',
              '৳5.00',
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildFeeRow(
              'Sell করার সময় Binance commission',
              '0.20%',
              Colors.red,
            ),
            _buildFeeRow(
              'Sell করার সময় buyer অতিরিক্ত দেয়',
              '1.80%',
              Colors.green,
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'নোট: উপরের calculation এ সব fees এবং charges হিসাব করা আছে। আপনার actual transactions এর data থেকে average buy rate বের করা হয়েছে।',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitScenariosTable(OptimalPricingModel model) {
    final scenarios = [
      {'profit': 0.50, 'label': '৳0.50'},
      {'profit': 1.00, 'label': '৳1.00'},
      {'profit': 1.50, 'label': '৳1.50'},
      {'profit': 2.00, 'label': '৳2.00'},
      {'profit': 3.00, 'label': '৳3.00'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'বিভিন্ন লাভের জন্য Binance Unit Price',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'বিভিন্ন profit targets এর জন্য আপনাকে কত rate set করতে হবে',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Divider(height: 24),
            Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    _buildTableHeader('লাভ/USDT'),
                    _buildTableHeader('Unit Price'),
                    _buildTableHeader('100 USDT লাভ'),
                  ],
                ),
                ...scenarios.map((scenario) {
                  final profit = scenario['profit'] as double;
                  final label = scenario['label'] as String;
                  // Calculate Binance unit price for this profit
                  final binancePrice = model.avgBuyRate > 0
                      ? (profit + (1.002 * model.avgBuyRate)) / 1.0185
                      : 0.0;
                  final totalProfit = profit * 100;
                  final isRecommended = profit == 1.00;

                  return TableRow(
                    decoration: BoxDecoration(
                      color: isRecommended
                          ? Colors.green.shade50
                          : Colors.transparent,
                    ),
                    children: [
                      _buildTableCell(label, isRecommended),
                      _buildTableCell(
                        '৳${binancePrice.toStringAsFixed(2)}',
                        isRecommended,
                      ),
                      _buildTableCell(
                        '৳${totalProfit.toStringAsFixed(2)}',
                        isRecommended,
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Unit Price এ buyer এর 1.80% bonus যোগ হয়ে effective rate হয়',
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, bool isHighlighted) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Card(
      elevation: 2,
      color: Colors.purple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                const Text(
                  'কীভাবে কাজ করে?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildExplanationPoint(
              '১.',
              'এই calculator আপনার সব buy transactions analyze করে average buy rate বের করে।',
            ),
            _buildExplanationPoint(
              '২.',
              'Average buy rate এ সব fees, commissions এবং manual charges যুক্ত আছে।',
            ),
            _buildExplanationPoint(
              '৩.',
              'আপনি যে পরিমাণ লাভ চান সেটা average buy rate এর সাথে যোগ করলেই required sell rate পাবেন।',
            ),
            _buildExplanationPoint(
              '৪.',
              'উদাহরণ: যদি average buy rate হয় ৳120.50 এবং আপনি ৳1.00 লাভ চান, তাহলে sell rate হবে ৳121.50',
            ),
            _buildExplanationPoint(
              '৫.',
              'বিভিন্ন মাসের data দেখতে উপরে থেকে মাস select করুন।',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationPoint(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
