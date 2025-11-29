import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/db_helper.dart';
import '../../models/daily_spend.dart';
import '../daily_spending/add_daily_spending_screen.dart';

class MoneyLeftScreen extends StatefulWidget {
  const MoneyLeftScreen({super.key});

  @override
  State<MoneyLeftScreen> createState() => _MoneyLeftScreenState();
}

class _MoneyLeftScreenState extends State<MoneyLeftScreen> {
  final db = DBHelper();
  double totalIncome = 0.0;
  double totalFixed = 0.0;
  List<DailySpend> dailySpendings = [];

  final Random random = Random();
  final int numParticles = 25;
  List<Offset> particlePositions = [];

  @override
  void initState() {
    super.initState();
    _loadParticles();
    _loadData();
  }

  void _loadParticles() {
    for (int i = 0; i < numParticles; i++) {
      particlePositions.add(Offset(random.nextDouble(), random.nextDouble()));
    }

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        particlePositions = particlePositions.map((p) {
          double dx = p.dx + (random.nextDouble() - 0.5) * 0.01;
          double dy = p.dy + (random.nextDouble() - 0.5) * 0.01;
          return Offset(dx.clamp(0.0, 1.0), dy.clamp(0.0, 1.0));
        }).toList();
      });
    });
  }

  Future<void> _loadData() async {
    final inc = await db.getLatestIncome();
    final fixed = await db.totalFixedExpenses();
    final spendings = await db.getAllDailySpends();

    setState(() {
      totalIncome = inc;
      totalFixed = fixed;
      dailySpendings = spendings;
    });
  }

  Widget _buildParticles(double width, double height) {
    return Stack(
      children: particlePositions.map((p) {
        return Positioned(
          left: p.dx * width,
          top: p.dy * height,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget glassCard({required Widget child, double blur = 15}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  IconData _iconFor(String key) {
    switch (key) {
      case "Savings":
        return Icons.savings_outlined;
      case "Food & Drink & Provisions":
        return Icons.fastfood_outlined;
      case "Phone & Fuel & Wash":
        return Icons.local_gas_station_outlined;
      case "Reserve Fund":
        return Icons.wallet_giftcard_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final moneyLeft = (totalIncome - totalFixed).clamp(0.0, double.infinity);

    final categories = {
      "Savings": 0.25,
      "Food & Drink & Provisions": 0.50,
      "Phone & Fuel & Wash": 0.15,
      "Reserve Fund": 0.10,
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    size: 32,
                    color: Color(0xFF2E5D38),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 18,
                right: 20,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 70,
                      height: 30,
                    ),
                    const Text(
                      "ChatCheng Louy",
                      style: TextStyle(
                        color: Color(0xFF2E5D38),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3F2E1),
                  Color(0xFFCDE4C7),
                  Color(0xFFAECFAF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _buildParticles(size.width, size.height),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  glassCard(
                    child: Column(
                      children: [
                        _summaryRow("Total Income", totalIncome),
                        const SizedBox(height: 6),
                        _summaryRow("Fixed Expenses", totalFixed),
                        const Divider(height: 16, color: Colors.white30),
                        _summaryRow("Money Left", moneyLeft, highlight: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Money Distribution",
                    style: TextStyle(
                      color: Color(0xFF2E5D38),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Money Distribution per Category
                  ...categories.entries.map((e) {
                    final percent = e.value * 100;
                    final categoryTotal = dailySpendings
                        .where((d) => d.category == e.key)
                        .fold(0.0, (sum, d) => sum + d.amount);
                    final allowed = moneyLeft * e.value;
                    final remaining = (allowed - categoryTotal).clamp(
                      0.0,
                      allowed,
                    );
                    final progress =
                        (categoryTotal / (allowed == 0 ? 1 : allowed)).clamp(
                          0.0,
                          1.0,
                        );

                    return glassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Icon(
                                  _iconFor(e.key),
                                  color: const Color(0xFF2E5D38),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${e.key} (${percent.toInt()}%)",
                                      style: const TextStyle(
                                        color: Color(0xFF2E5D38),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "\$${remaining.toStringAsFixed(2)} left",
                                      style: const TextStyle(
                                        color: Color(0xFF2E5D38),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Color(0xFF2E5D38),
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddDailySpendingScreen(
                                        preselectedCategory: e.key,
                                      ),
                                    ),
                                  );
                                  if (result == true) await _loadData();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            color: Colors.green.shade700,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  const Text(
                    "Daily Spendings",
                    style: TextStyle(
                      color: Color(0xFF2E5D38),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Daily Spending List
                  ...dailySpendings.map(
                    (d) => glassCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(
                              _iconFor(d.category),
                              color: const Color(0xFF2E5D38),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.title,
                                  style: const TextStyle(
                                    color: Color(0xFF2E5D38),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${d.category} ${DateFormat('dd-MM-yyyy').format(DateTime.parse(d.date))}",
                                  style: const TextStyle(
                                    color: Color(0xFF2E5D38),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "-\$${d.amount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color(0xFF2E5D38),
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddDailySpendingScreen(
                                                editDailySpend: d,
                                                preselectedCategory: d.category,
                                              ),
                                        ),
                                      );
                                      if (result == true) await _loadData();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      await db.deleteDailySpend(d.id!);
                                      await _loadData();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E5D38),
          ),
        ),
        Text(
          "\$${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: highlight ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.green.shade800 : const Color(0xFF2E5D38),
          ),
        ),
      ],
    );
  }
}
