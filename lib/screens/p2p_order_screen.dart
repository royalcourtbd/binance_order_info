import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controllers/orders_controller.dart';
import '../models/balance_model.dart';
import '../widgets/month_section.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'pricing_calculator_screen.dart';

class P2POrderScreen extends StatefulWidget {
  const P2POrderScreen({super.key});

  @override
  State<P2POrderScreen> createState() => _P2POrderScreenState();
}

class _P2POrderScreenState extends State<P2POrderScreen> {
  final OrdersController controller = Get.put(OrdersController());
  late PageController _pageController;
  final RxInt _currentPageIndex = 0.obs;
  DateTime? _lastBackPress;

  void _showBackExitNotice(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Exit করতে আবার back চাপুন'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    // Initialize PageController
    _pageController = PageController(initialPage: 0);

    // When data loads for the FIRST TIME, jump to current month
    // Using 'once' instead of 'ever' so it only triggers on first data load
    once(controller.monthSections, (_) {
      if (controller.monthSections.isNotEmpty && _pageController.hasClients) {
        final currentMonthPage = controller.getCurrentMonthIndex();
        // Jump to current month instantly (only on first load)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(currentMonthPage);
            _currentPageIndex.value = currentMonthPage;
          }
        });
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        final now = DateTime.now();
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          _showBackExitNotice(context);
          return;
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
            // Calculator button
            IconButton(
              icon: const Icon(Icons.calculate, color: Colors.black),
              tooltip: 'Price Calculator',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PricingCalculatorScreen(),
                  ),
                );
              },
            ),
            // Refresh button
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
          return RefreshIndicator(
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
              return Column(
                children: [
                  // USDT Balance Display
                  Obx(() {
                    // Find USDT asset from funding wallet
                    final usdtAsset = controller
                        .balance
                        .value
                        .data
                        .fundingWallet
                        .firstWhere(
                          (asset) => asset.asset == 'USDT',
                          orElse: () => AssetBalance(
                            asset: 'USDT',
                            free: '0',
                            locked: '0',
                            withdrawing: '0',
                            btcValuation: '0',
                            total: 0.0,
                          ),
                        );

                    final free = double.tryParse(usdtAsset.free) ?? 0.0;
                    final locked = double.tryParse(usdtAsset.locked) ?? 0.0;
                    final total = usdtAsset.total;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF0B90B), Color(0xFFFCD535)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: .3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'USDT Balance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildBalanceRow('Free', free, 'Available balance'),
                          const SizedBox(height: 8),
                          _buildBalanceRow('Locked', locked, 'Pending orders'),
                          const SizedBox(height: 8),
                          _buildBalanceRow('Total', total, 'Free + Locked'),
                        ],
                      ),
                    );
                  }),
                  // PageView for month sections
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: controller.monthSections.length,
                      onPageChanged: (index) {
                        _currentPageIndex.value = index;
                      },
                      itemBuilder: (context, index) {
                        return MonthSection(
                          model: controller.monthSections[index],
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildBalanceRow(String label, double amount, String description) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${amount.toStringAsFixed(2)} USDT)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Text(
          description,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
