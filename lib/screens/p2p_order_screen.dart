import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/orders_controller.dart';
import '../widgets/summary_item.dart';
import '../widgets/month_section.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/ip_config_dialog.dart';

class P2POrderScreen extends StatefulWidget {
  const P2POrderScreen({super.key});

  @override
  State<P2POrderScreen> createState() => _P2POrderScreenState();
}

class _P2POrderScreenState extends State<P2POrderScreen> {
  final OrdersController controller = Get.put(OrdersController());
  late PageController _pageController;
  final RxInt _currentPageIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    // Initialize PageController
    _pageController = PageController(initialPage: 0);

    // When data loads, jump to current month
    ever(controller.monthSections, (_) {
      if (controller.monthSections.isNotEmpty && _pageController.hasClients) {
        final currentMonthPage = controller.getCurrentMonthIndex();
        if (currentMonthPage != _currentPageIndex.value) {
          // Jump to current month instantly (only on first load)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(currentMonthPage);
              _currentPageIndex.value = currentMonthPage;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => IpConfigDialog(
                onIpChanged: () => controller.refreshOrders(),
              ),
            );
          },
        ),
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
        if (controller.isLoading.value && controller.monthSections.isEmpty) {
          return const LoadingWidget(message: 'Fetching orders from API...');
        }

        // Error state
        if (controller.errorMessage.isNotEmpty &&
            controller.monthSections.isEmpty) {
          return ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: () => controller.refreshOrders(),
          );
        }

        // Empty state
        if (controller.monthSections.isEmpty) {
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

            // Month indicator with navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Obx(() {
                if (controller.monthSections.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPageIndex.value < controller.monthSections.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                    ),
                    Obx(() => Text(
                      _currentPageIndex.value < controller.monthSections.length
                          ? controller.monthSections[_currentPageIndex.value].monthName
                          : '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPageIndex.value > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                    ),
                  ],
                );
              }),
            ),

            // Monthly PageView with pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshOrders(),
                child: Obx(() {
                  if (controller.monthSections.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(
                          height: 200,
                          child: Center(child: Text('No data')),
                        ),
                      ],
                    );
                  }
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: controller.monthSections.length,
                    onPageChanged: (index) {
                      _currentPageIndex.value = index;
                    },
                    itemBuilder: (context, index) {
                      return MonthSection(model: controller.monthSections[index]);
                    },
                  );
                }),
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
