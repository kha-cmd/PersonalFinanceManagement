// lib/screens/daily_spending/add_daily_spending_screen.dart

import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/db_helper.dart';
import '../../models/daily_spend.dart';

class AddDailySpendingScreen extends StatefulWidget {
  final DailySpend? editDailySpend;
  final String? preselectedCategory;

  const AddDailySpendingScreen({super.key, this.editDailySpend, this.preselectedCategory});

  @override
  State<AddDailySpendingScreen> createState() => _AddDailySpendingScreenState();
}

class _AddDailySpendingScreenState extends State<AddDailySpendingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final db = DBHelper();

  String category = 'Savings';
  DateTime selectedDate = DateTime.now();

  final Random random = Random();
  final int numParticles = 25;
  List<Offset> particlePositions = [];

  @override
  void initState() {
    super.initState();

    // Pre-fill for editing
    if (widget.editDailySpend != null) {
      _titleController.text = widget.editDailySpend!.title;
      _amountController.text = widget.editDailySpend!.amount.toString();
      category = widget.editDailySpend!.category;
      selectedDate = DateTime.parse(widget.editDailySpend!.date);
    } else if (widget.preselectedCategory != null) {
      category = widget.preselectedCategory!;
    }

    _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);

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

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final spend = DailySpend(
      id: widget.editDailySpend?.id,
      title: _titleController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
      category: category,
      date: selectedDate.toIso8601String(),
    );

    if (widget.editDailySpend != null) {
      await db.updateDailySpend(spend);
    } else {
      await db.insertDailySpend(spend);
    }

    Navigator.pop(context, true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2E5D38),
            onPrimary: Colors.white,
            onSurface: Color(0xFF2E5D38),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  Widget _buildParticles(double w, double h) {
    return Stack(
      children: particlePositions.map((p) {
        return Positioned(
          left: p.dx * w,
          top: p.dy * h,
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

  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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

  InputDecoration _inputStyle({required String label, IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF2E5D38)) : null,
      labelStyle: const TextStyle(color: Color(0xFF2E5D38)),
      hintStyle: const TextStyle(color: Color(0xFF2E5D38)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E5D38)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E5D38), width: 2),
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
                  icon: const Icon(Icons.chevron_left_rounded, size: 32, color: Color(0xFF2E5D38)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 18,
                right: 20,
                child: Column(
                  children: const [
                    Image(
                      image: AssetImage('assets/images/logo.png'),
                      width: 70,
                      height: 30,
                    ),
                    Text(
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
                colors: [Color(0xFFE3F2E1), Color(0xFFCDE4C7), Color(0xFFAECFAF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _buildParticles(size.width, size.height),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          widget.editDailySpend != null ? "Edit Daily Spending" : "Add Daily Spending",
                          style: const TextStyle(
                            color: Color(0xFF2E5D38),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: Color(0xFF2E5D38)),
                          decoration: _inputStyle(label: "Title", hint: "e.g. Lunch, Coffee"),
                          validator: (v) => v!.isEmpty ? "Please enter a title" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Color(0xFF2E5D38)),
                          decoration: _inputStyle(label: "Amount (USD)", icon: Icons.attach_money),
                          validator: (v) => v!.isEmpty ? "Please enter an amount" : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: category,
                          decoration: _inputStyle(label: "Category", icon: Icons.category),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Color(0xFF2E5D38)),
                          items: const [
                            DropdownMenuItem(value: 'Savings', child: Text('Savings')),
                            DropdownMenuItem(
                                value: 'Food & Drink & Provisions',
                                child: Text('Food & Drink & Provisions')),
                            DropdownMenuItem(value: 'Phone & Fuel & Wash', child: Text('Phone / Fuel / Wash')),
                            DropdownMenuItem(value: 'Reserve Fund', child: Text('Reserve Fund')),
                          ],
                          onChanged: (v) => setState(() => category = v!),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          style: const TextStyle(color: Color(0xFF2E5D38)),
                          decoration: _inputStyle(label: "Date", icon: Icons.calendar_today),
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save, color: Color(0xFF2E5D38)),
                            label: Text(
                              widget.editDailySpend != null ? "Update Spending" : "Save Spending",
                              style: const TextStyle(color: Color(0xFF2E5D38), fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.4),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
