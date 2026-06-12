import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/locale_provider.dart';

class TransactionFormSheet extends StatefulWidget {
  final TransactionModel? existing;

  const TransactionFormSheet({super.key, this.existing});

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey          = GlobalKey<FormState>();
  final _titleController  = TextEditingController();
  final _amountController = TextEditingController();

  String   _type         = 'income';
  DateTime _selectedDate = DateTime.now();
  bool get _isEdit       => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final tx = widget.existing!;
      _titleController.text  = tx.title;
      _amountController.text = tx.amount % 1 == 0
          ? tx.amount.toInt().toString()
          : tx.amount.toString();
      _type          = tx.type;
      _selectedDate  = tx.createdAt ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final txProvider   = Provider.of<TransactionProvider>(context, listen: false);
    final locale       = Provider.of<LocaleProvider>(context, listen: false);
    final userId       = authProvider.currentUser?.id ?? '';
    final amount       = double.tryParse(_amountController.text) ?? 0.0;

    try {
      if (_isEdit) {
        final updated = TransactionModel(
          id:        widget.existing!.id,
          title:     _titleController.text.trim(),
          amount:    amount,
          type:      _type,
          createdAt: _selectedDate,
          userId:    userId,
        );
        await txProvider.editTransaction(updated, userId);
      } else {
        final newTx = TransactionModel(
          title:     _titleController.text.trim(),
          amount:    amount,
          type:      _type,
          createdAt: _selectedDate,
          userId:    userId,
        );
        await txProvider.addTransaction(newTx, userId);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(_isEdit ? locale.t('snack_updated') : locale.t('snack_inserted')),
              ],
            ),
            backgroundColor: AppColors.snackbarSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProvider    = Provider.of<TransactionProvider>(context);
    final locale        = Provider.of<LocaleProvider>(context);
    final theme         = Theme.of(context);
    final isDark        = theme.brightness == Brightness.dark;
    final dateFormatted = DateFormat('d/M/yyyy').format(_selectedDate);

    final sheetBg  = isDark ? const Color(0xFF26203A) : Colors.white;
    final fieldBg  = isDark ? const Color(0xFF2E2845) : const Color(0xFFF5F5F5);
    final fieldBrd = isDark ? const Color(0xFF3D3050) : const Color(0xFFE5E7EB);
    final hintCol  = isDark ? const Color(0xFF8A7E82) : const Color(0xFFADB5BD);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.only(
          topLeft:  Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left:   24,
        right:  24,
        top:    16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3D3050) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Ícono
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _isEdit
                        ? Colors.orange.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isEdit ? Icons.edit_note_rounded : Icons.account_balance_wallet_rounded,
                    color: _isEdit ? Colors.orange : AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Título
              Text(
                locale.t(_isEdit ? 'edit_movement' : 'new_movement'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _isEdit ? Colors.orange : AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                locale.t(_isEdit ? 'edit_movement_sub' : 'new_movement_sub'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: hintCol),
              ),
              const SizedBox(height: 24),

              // Tipo de movimiento
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: fieldBrd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.t('movement_type'),
                      style: TextStyle(fontSize: 11, color: hintCol),
                    ),
                    InkWell(
                      onTap: () => setState(() {
                        _type = _type == 'income' ? 'expense' : 'income';
                      }),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              _type == 'income'
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: _type == 'income'
                                  ? AppColors.incomeGreen
                                  : AppColors.expenseRed,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              locale.t(_type == 'income' ? 'income_type' : 'expense_type'),
                              style: TextStyle(fontSize: 15, color: hintCol),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Descripción
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: locale.t('description'),
                  hintText: locale.t(_type == 'income' ? 'salary_hint' : 'food_hint'),
                  prefixIcon: Icon(Icons.description_outlined, color: hintCol),
                  filled: true,
                  fillColor: fieldBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: fieldBrd),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: fieldBrd),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return locale.t('enter_desc');
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Valor
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: locale.t('value'),
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: hintCol),
                  filled: true,
                  fillColor: fieldBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: fieldBrd),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: fieldBrd),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return locale.t('enter_value');
                  final val = double.tryParse(value);
                  if (val == null || val <= 0) return locale.t('invalid_amount');
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Fecha
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: fieldBrd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, color: hintCol),
                      const SizedBox(width: 10),
                      Text(
                        dateFormatted,
                        style: TextStyle(fontSize: 15, color: hintCol),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: hintCol),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Botón guardar/actualizar
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEdit ? Colors.orange : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: txProvider.isLoading ? null : _submit,
                  icon: txProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded, size: 20),
                  label: Text(
                    locale.t(_isEdit ? 'update_movement' : 'save_movement'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
