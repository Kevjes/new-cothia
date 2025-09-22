import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/budgets_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import 'budgets_dashboard.dart';
import 'budgets_list.dart';
import 'budgets_stats.dart';

class BudgetsMain extends StatefulWidget {
  const BudgetsMain({Key? key}) : super(key: key);

  @override
  State<BudgetsMain> createState() => _BudgetsMainState();
}

class _BudgetsMainState extends State<BudgetsMain> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageIndex = ValueNotifier<int>(0);

  final List<String> _pageLabels = [
    'Tableau de Bord',
    'Liste',
    'Statistiques',
  ];

  final List<IconData> _pageIcons = [
    Icons.dashboard,
    Icons.list,
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
    Get.put<BudgetsController>(BudgetsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Objectifs'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ValueListenableBuilder<int>(
            valueListenable: _currentPageIndex,
            builder: (context, currentIndex, child) {
              return Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: List.generate(
                            _pageLabels.length,
                            (index) => Expanded(
                              child: GestureDetector(
                                onTap: () => _changePage(index),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: currentIndex == index
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _pageIcons[index],
                                        size: 18,
                                        color: currentIndex == index
                                            ? Colors.white
                                            : AppColors.grey600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _pageLabels[index],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: currentIndex == index
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: currentIndex == index
                                              ? Colors.white
                                              : AppColors.grey600,
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
                    ),
                  ],
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
          BudgetsDashboard(),
          BudgetsList(),
          BudgetsStats(),
        ],
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