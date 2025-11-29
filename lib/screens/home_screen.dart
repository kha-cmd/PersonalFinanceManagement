import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/income.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _incomeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final db = DBHelper();

  double totalIncome = 0.0;
  double totalFixed = 0.0;

  final Random random = Random();
  final int numParticles = 25;
  List<Offset> particlePositions = [];

  @override
  void initState() {
    super.initState();
    _loadValues();

    // Initialize particle positions
    for (int i = 0; i < numParticles; i++) {
      particlePositions.add(Offset(random.nextDouble(), random.nextDouble()));
    }

    // Animate particles
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

  Future<void> _loadValues() async {
    final inc = await db.getLatestIncome();
    final fixed = await db.totalFixedExpenses();
    setState(() {
      totalIncome = inc;
      totalFixed = fixed;
      _incomeController.text = inc == 0.0 ? '' : inc.toStringAsFixed(2);
    });
  }

  Future<void> _saveIncome() async {
    final text = _incomeController.text.trim();
    final parsed = double.tryParse(text) ?? 0.0;
    final inc = Income(
      totalIncome: parsed,
      date: selectedDate.toIso8601String(),
    );
    await db.insertIncome(inc);
    await _loadValues();
  }

  Widget _buildParticles(double width, double height) {
    return Stack(
      children: particlePositions.map((p) {
        return Positioned(
          left: p.dx * width,
          top: p.dy * height,
          child: Container(
            width: 6,
            height: 6,
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
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moneyLeft = (totalIncome - totalFixed).clamp(0.0, double.infinity);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // 🌿 Nature Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3F2E1), // bamboo mist
                  Color(0xFFCDE4C7), // soft plant green
                  Color(0xFFAECFAF), // muted natural green
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✨ Particles
          _buildParticles(size.width, size.height),

          // 🌟 Top-right big logo with text
          Positioned(
            top: 50,
            right: 20,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 70,
                  height: 30,
                ),
                //const SizedBox(height: 6),
                const Text(
                  "ChatCheng Louy",
                  style: TextStyle(
                    color: Color(0xFF2E5D38), // dark soft green
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // 🏠 Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 60), // leave space for logo

                  // Total Income
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Total Income",
                      style: TextStyle(
                        color: Color(0xFF2E5D38),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  glassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: TextField(
                        controller: _incomeController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: Color(0xFF2E5D38)),
                        decoration: InputDecoration(
                          labelText: 'Enter Total Income (USD)',
                          labelStyle: TextStyle(
                              color: Color(0xFF2E5D38).withOpacity(0.7)),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF2E5D38),
                            ),
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) setState(() => selectedDate = d);
                            },
                          ),
                        ),
                        onSubmitted: (_) => _saveIncome(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${DateFormat.yMMMd().format(selectedDate)}',
                        style: TextStyle(
                            color: Color(0xFF2E5D38).withOpacity(0.7),
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Summary
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Summary",
                      style: TextStyle(
                        color: Color(0xFF2E5D38),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  glassCard(
                    child: ListTile(
                      leading: const Icon(Icons.category_rounded,
                          color: Color(0xFF2E5D38)),
                      title: const Text(
                        'Fixed Expenses',
                        style: TextStyle(color: Color(0xFF2E5D38)),
                      ),

                      // ✅ Subtitle shows the total fixed expenses
                      subtitle: Text(
                        '\$${totalFixed.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black54),
                      ),

                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Color(0xFF2E5D38), size: 16),
                      onTap: () async {
                        await Navigator.pushNamed(context, '/fixed_expense');
                        await _loadValues();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  glassCard(
                    child: ListTile(
                      leading: const Icon(Icons.wallet_rounded,
                          color: Color(0xFF2E5D38)),
                      title: const Text(
                        'Remaining Money',
                        style: TextStyle(color: Color(0xFF2E5D38)),
                      ),

                      // ✅ Subtitle shows the remaining balance
                      subtitle: Text(
                        '\$${moneyLeft.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black54),
                      ),

                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Color(0xFF2E5D38), size: 16),
                      onTap: () async {
                        await Navigator.pushNamed(context, '/money_left');
                        await _loadValues();
                      },
                    ),
                  ),
                  //const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
