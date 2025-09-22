import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import 'transactions_dashboard.dart';
import 'transactions_categories.dart';
import 'transactions_stats.dart';

class TransactionsMain extends StatefulWidget {
  const TransactionsMain({Key? key}) : super(key: key);

  @override
  State<TransactionsMain> createState() => _TransactionsMainState();
}

class _TransactionsMainState extends State<TransactionsMain> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageIndex = ValueNotifier<int>(0);

  final List<String> _pageLabels = [
    'Tableau de Bord',
    'Catégories',
    'Statistiques',
  ];

  final List<IconData> _pageIcons = [
    Icons.dashboard,
    Icons.category,
    Icons.analytics,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: ValueListenableBuilder<int>(
            valueListenable: _currentPageIndex,
            builder: (context, currentIndex, child) {
              return Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      _pageLabels.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          right: index < _pageLabels.length - 1 ? 12 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => _changePage(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: currentIndex == index
                                  ? AppColors.primary
                                  : Get.theme.brightness == Brightness.dark
                                      ? AppColors.grey800.withOpacity(0.6)
                                      : AppColors.grey100,
                              borderRadius: BorderRadius.circular(25),
                              border: currentIndex != index
                                  ? Border.all(
                                      color: Get.theme.brightness == Brightness.dark
                                          ? AppColors.grey700
                                          : AppColors.grey300,
                                      width: 1,
                                    )
                                  : null,
                              boxShadow: currentIndex == index
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _pageIcons[index],
                                  size: 20,
                                  color: currentIndex == index
                                      ? Colors.white
                                      : Get.theme.brightness == Brightness.dark
                                          ? AppColors.grey300
                                          : AppColors.grey600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _pageLabels[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: currentIndex == index
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: currentIndex == index
                                        ? Colors.white
                                        : Get.theme.brightness == Brightness.dark
                                            ? AppColors.grey300
                                            : AppColors.grey700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => _currentPageIndex.value = index,
        children: const [
          TransactionsDashboard(),
          TransactionsCategories(),
          TransactionsStats(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/finance/add-transaction'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _changePage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}