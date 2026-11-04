import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/expense_transaction.dart';
import '../../data/providers/transaction_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, required this.provider, this.transaction});

  final TransactionProvider provider;
  final ExpenseTransaction? transaction;

  bool get isEditing => transaction != null;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  String? _category;
  String? _type;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.transaction;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(text: existing == null ? '' : _amountText(existing.amount));
    _category = existing?.category;
    _type = existing?.type;
    _selectedDate = existing?.date ?? DateTime.now();
  }

  String _amountText(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final amount = double.parse(_amountController.text.trim());
    final updated = ExpenseTransaction(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: amount,
      category: _category!,
      type: _type!,
      date: _selectedDate,
    );

    try {
      if (widget.isEditing) {
        await widget.provider.updateTransaction(updated);
      } else {
        await widget.provider.addTransaction(updated);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save transaction: $error'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit transaction' : 'New transaction'),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(color: AppColors.violetSoft, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 23)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Keep your records clear', style: TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('Every entry is saved securely on this device.', style: TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Transaction type'),
            const SizedBox(height: 9),
            FormField<String>(
              initialValue: _type,
              validator: (value) => value == null ? 'Please select a transaction type' : null,
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _TypeChoice(label: 'Expense', subtitle: 'Money out', icon: Icons.north_east_rounded, selected: field.value == 'expense', color: AppColors.expense, onTap: () { field.didChange('expense'); setState(() => _type = 'expense'); })),
                        const SizedBox(width: 10),
                        Expanded(child: _TypeChoice(label: 'Income', subtitle: 'Money in', icon: Icons.south_west_rounded, selected: field.value == 'income', color: AppColors.income, onTap: () { field.didChange('income'); setState(() => _type = 'income'); })),
                      ],
                    ),
                    if (field.hasError)
                      Padding(padding: const EdgeInsets.only(left: 12, top: 6), child: Text(field.errorText!, style: const TextStyle(color: AppColors.expense, fontSize: 11))),
                  ],
                );
              },
            ),
            const SizedBox(height: 21),
            const _FieldLabel('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              maxLength: 60,
              decoration: const InputDecoration(hintText: 'e.g. Monthly salary, Grocery shopping', prefixIcon: Icon(Icons.title_rounded)),
              validator: (value) => value == null || value.trim().isEmpty ? 'Title cannot be empty' : null,
            ),
            const SizedBox(height: 8),
            const _FieldLabel('Amount'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(hintText: '0.00', prefixIcon: Icon(Icons.currency_exchange_rounded), prefixText: '৳  '),
              validator: (value) {
                final amount = double.tryParse((value ?? '').trim());
                if (value == null || value.trim().isEmpty) return 'Amount is required';
                if (amount == null || !amount.isFinite || amount <= 0) return 'Enter a valid amount greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 17),
            const _FieldLabel('Category'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              isExpanded: true,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined), hintText: 'Choose a category'),
              items: AppCategories.all.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(AppCategories.iconFor(category), size: 18, color: AppCategories.colorFor(category)),
                      const SizedBox(width: 10),
                      Text(category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _category = value),
              validator: (value) => value == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 17),
            const _FieldLabel('Date'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: AppColors.muted),
                    const SizedBox(width: 12),
                    Expanded(child: Text(formatDate(_selectedDate), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink))),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_rounded),
            label: Text(_isSaving ? 'Saving...' : widget.isEditing ? 'Save changes' : 'Save transaction'),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(color: AppColors.ink, fontSize: 12, fontWeight: FontWeight.w800));
  }
}

class _TypeChoice extends StatelessWidget {
  const _TypeChoice({required this.label, required this.subtitle, required this.icon, required this.selected, required this.color, required this.onTap});

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(.09) : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: selected ? color.withOpacity(.55) : AppColors.line, width: selected ? 1.4 : 1),
        ),
        child: Row(
          children: [
            Container(width: 35, height: 35, decoration: BoxDecoration(color: color.withOpacity(.13), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 9.5, fontWeight: FontWeight.w600))])),
            if (selected) Icon(Icons.check_circle_rounded, color: color, size: 17),
          ],
        ),
      ),
    );
  }
}
