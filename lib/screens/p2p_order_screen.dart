import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/orders_controller.dart';
import '../widgets/summary_item.dart';
import '../widgets/date_section.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';

class P2POrderScreen extends StatelessWidget {
  P2POrderScreen({super.key});

  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Binance P2P Orders',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.black),
                    onPressed: () => controller.refreshOrders(),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value && controller.dateSections.isEmpty) {
          return const LoadingWidget(message: 'Fetching orders from API...');
        }

        // Error state
        if (controller.errorMessage.isNotEmpty &&
            controller.dateSections.isEmpty) {
          return ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: () => controller.refreshOrders(),
          );
        }

        // Empty state
        if (controller.dateSections.isEmpty) {
          return const EmptyStateWidget();
        }

        // Success state with data
        return Column(
          children: [
            // Top Summary Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SummaryItem(
                    label: "Buy",
                    totalAmountUsdt: _formatAmount(
                      controller.summary.value.totalBuyAmount,
                    ),
                    totalAmountBdt: _formatAmount(
                      controller.summary.value.totalBuyValue,
                    ),
                    color: Colors.blue,
                  ),
                  SummaryItem(
                    label: "Sell",
                    totalAmountUsdt: _formatAmount(
                      controller.summary.value.totalSellAmount,
                    ),
                    totalAmountBdt: _formatAmount(
                      controller.summary.value.totalSellValue,
                    ),
                    color: Colors.red,
                  ),

                  SummaryItem(
                    label: "Profit",
                    totalAmountUsdt: _formatAmount(
                      controller.summary.value.netProfitBdt,
                    ),
                    color: controller.summary.value.netProfitBdt >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),

            // Transaction List with pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshOrders(),
                child: ListView.builder(
                  itemCount: controller.dateSections.length,
                  itemBuilder: (context, index) {
                    return DateSection(model: controller.dateSections[index]);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }
}
