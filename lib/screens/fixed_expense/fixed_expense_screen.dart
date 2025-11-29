import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/fixed_expense.dart';
import 'add_fixed_expense_screen.dart';

class FixedExpenseScreen extends StatefulWidget {
  const FixedExpenseScreen({super.key});

  @override
  State<FixedExpenseScreen> createState() => _FixedExpenseScreenState();
}

class _FixedExpenseScreenState extends State<FixedExpenseScreen> {
  final db = DBHelper();
  List<FixedExpense> items = [];
  double total = 0.0;

  final Random random = Random();
  final int numParticles = 25;
  List<Offset> particlePositions = [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadParticles();
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

  Future<void> _load() async {
    final list = await db.getAllFixedExpenses();
    final tot = await db.totalFixedExpenses();
    setState(() {
      items = list;
      total = tot;
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

  IconData _iconFor(String category) {
    switch (category.toLowerCase()) {
      case "rent":
        return Icons.home_outlined;
      case "internet":
        return Icons.wifi;
      case "electricity":
        return Icons.flash_on_outlined;
      case "water":
        return Icons.water_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  Widget _expenseTile(FixedExpense f) {
    Color statusColor;
    if (f.status.toLowerCase() == "obligation") {
      statusColor = Colors.red.shade200;
    } else if (f.status.toLowerCase() == "essential requirement") {
      statusColor = Colors.green.shade200;
    } else {
      statusColor = Colors.grey.shade300;
    }

    // Format date MM-dd-yyyy
    String formattedDate = "";
    try {
      DateTime d = DateTime.parse(f.date);
      formattedDate =
          "${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}-${d.year}";
    } catch (e) {
      formattedDate = f.date;
    }

    return glassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON LEFT
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(_iconFor(f.category), color: const Color(0xFF2E5D38), size: 20),
          ),
          const SizedBox(width: 12),

          // TEXTS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CATEGORY
                Text(
                  f.category,
                  style: const TextStyle(
                      color: Color(0xFF2E5D38), fontWeight: FontWeight.bold, fontSize: 14),
                ),

                const SizedBox(height: 4),

                // AMOUNT
                Text(
                  "-\$${f.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                // STATUS
                Text(
                  f.status,
                  style: TextStyle(
                      color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),

                // DATE BELOW STATUS
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),

          // ACTION BUTTONS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF2E5D38), size: 18),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddFixedExpenseScreen(editFixedExpense: f, hideDelete: true),
                    ),
                  );
                  if (result == true) await _load();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                onPressed: () async {
                  await db.deleteFixedExpense(f.id!);
                  await _load();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                  icon: const Icon(Icons.chevron_left_rounded,
                      size: 32, color: Color(0xFF2E5D38)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 18,
                right: 20,
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', width: 70, height: 30),
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
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3F2E1),
                  Color(0xFFCDE4C7),
                  Color(0xFFAECFAF)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Particles
          _buildParticles(size.width, size.height),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  const Text(
                    "Fixed Expenses",
                    style: TextStyle(
                        color: Color(0xFF2E5D38),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // TOTAL CARD
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                        const EdgeInsets.symmetric(vertical: 28, horizontal: 90),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Total Fixed Expenses",
                          style: TextStyle(
                              color: Color(0xFF2E5D38), fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "\$${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Color(0xFF2E5D38),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // EXPENSES LIST
                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Text(
                              "No fixed expenses yet",
                              style:
                                  TextStyle(color: Color(0xFF2E5D38), fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (c, i) => _expenseTile(items[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Floating button
          Positioned(
            bottom: 18,
            right: 18,
            child: FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddFixedExpenseScreen()),
                );
                await _load();
              },
              icon: const Icon(Icons.add, color: Color(0xFF2E5D38)),
              label: const Text(
                "Add Expense",
                style: TextStyle(
                    color: Color(0xFF2E5D38), fontWeight: FontWeight.w700),
              ),
              backgroundColor: Colors.white.withOpacity(0.40),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
