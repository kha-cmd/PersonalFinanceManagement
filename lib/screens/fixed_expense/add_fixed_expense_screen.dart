// lib/screens/fixed_expense/add_fixed_expense_screen.dart

import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/fixed_expense.dart';
import '../../database/db_helper.dart';

class AddFixedExpenseScreen extends StatefulWidget {
  final FixedExpense? editFixedExpense;
  final bool hideDelete; // NEW flag

  const AddFixedExpenseScreen({
    Key? key,
    this.editFixedExpense,
    this.hideDelete = false, // default false
  }) : super(key: key);

  @override
  State<AddFixedExpenseScreen> createState() => _AddFixedExpenseScreenState();
}

class _AddFixedExpenseScreenState extends State<AddFixedExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _typeController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  String status = 'obligation';
  final db = DBHelper();

  final Random random = Random();
  final int numParticles = 25;
  List<Offset> particlePositions = [];

  @override
  void initState() {
    super.initState();

    // initialize particle positions
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

    // if editing, fill fields
    if (widget.editFixedExpense != null) {
      final fe = widget.editFixedExpense!;
      _categoryController.text = fe.category;
      _typeController.text = fe.type;
      _amountController.text = fe.amount.toString();
      _dateController.text = fe.date;
      status = fe.status;
    } else {
      final today = DateTime.now();
      _dateController.text = DateFormat('yyyy-MM-dd').format(today);
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _typeController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  InputDecoration _inputStyle({
    required String label,
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF2E5D38))
          : null,
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

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  String displayDateDDMMYYYY(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat('dd-MM-yyyy').format(d);
    } catch (_) {
      return iso;
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final fe = FixedExpense(
        id: widget.editFixedExpense?.id,
        category: _categoryController.text.trim(),
        type: _typeController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()) ?? 0,
        status: status,
        date: _dateController.text.trim(),
      );

      if (widget.editFixedExpense != null) {
        await db.updateFixedExpense(fe);
      } else {
        await db.insertFixedExpense(fe);
      }
      Navigator.pop(context, true);
    }
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
              child: glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          widget.editFixedExpense != null
                              ? "Edit Fixed Expense"
                              : "Add Fixed Expense",
                          style: const TextStyle(
                            color: Color(0xFF2E5D38),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _categoryController,
                          style: const TextStyle(color: Color(0xFF2E5D38)),
                          decoration: _inputStyle(
                            label: "Category",
                            icon: Icons.category_outlined,
                            hint: "e.g. Rent, Internet",
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Please enter category" : null,
                        ),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Color(0xFF2E5D38)),
                          decoration: _inputStyle(
                            label: "Amount (USD)",
                            icon: Icons.attach_money,
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Please enter amount" : null,
                        ),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: TextEditingController(
                            text: displayDateDDMMYYYY(_dateController.text),
                          ),
                          readOnly: true,
                          style: const TextStyle(color: Color(0xFF2E5D38)),
                          decoration: _inputStyle(
                            label: "Date",
                            icon: Icons.calendar_today,
                          ),
                          onTap: () async {
                            await _pickDate();
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 9),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: _inputStyle(
                            label: "Status",
                            icon: Icons.flag_circle_outlined,
                          ),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Color(0xFF2E5D38)),
                          items: const [
                            DropdownMenuItem(
                              value: 'obligation',
                              child: Text(
                                "Obligation",
                                style: TextStyle(color: Color(0xFF2E5D38)),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'essential requirement',
                              child: Text(
                                "Essential Requirement",
                                style: TextStyle(color: Color(0xFF2E5D38)),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => status = v!),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save, color: Color(0xFF2E5D38)),
                            label: Text(
                              widget.editFixedExpense != null ? "Update Expense" : "Save Expense",
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

  IconData _iconFor(String category) {
    switch (category) {
      case "Rent":
        return Icons.home_outlined;
      case "Internet":
        return Icons.wifi_outlined;
      case "Utilities":
        return Icons.lightbulb_outline;
      default:
        return Icons.receipt_long;
    }
  }
}
