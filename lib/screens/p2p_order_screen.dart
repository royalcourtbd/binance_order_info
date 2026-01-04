import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/orders_controller.dart';
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
        );
      }),
    );
  }
}
