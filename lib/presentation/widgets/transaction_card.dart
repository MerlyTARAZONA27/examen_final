import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/locale_provider.dart';

class TransactionCard extends StatefulWidget {
  final TransactionModel transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>   _animation;

  static const double _buttonWidth = 144; // 72 x 2 botones

  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = Tween<double>(begin: 0, end: -_buttonWidth).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open()   { _controller.forward(); setState(() => _revealed = true);  }
  void _close()  { _controller.reverse(); setState(() => _revealed = false); }
  void _toggle() => _revealed ? _close() : _open();

  void _confirmDelete() async {
    _close();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    final locale = Provider.of<LocaleProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   Text(locale.t('delete_title')),
        content: Text(locale.t('delete_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(locale.t('cancel'), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(locale.t('delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) widget.onDelete();
  }

  void _handleEdit() {
    _close();
    Future.delayed(const Duration(milliseconds: 200), widget.onEdit);
  }

  @override
  Widget build(BuildContext context) {
    final locale   = Provider.of<LocaleProvider>(context);
    final theme    = Theme.of(context);
    final isDark   = theme.brightness == Brightness.dark;

    final isIncome    = widget.transaction.isIncome;
    final amountColor = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final iconBgColor = isIncome
        ? AppColors.incomeGreen.withOpacity(0.15)
        : AppColors.expenseRed.withOpacity(0.15);
    final iconColor   = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final amountSign  = isIncome ? '+ \$' : '- \$';
    final typeLabel   = locale.t(isIncome ? 'card_income' : 'card_expense');

    // Card bg reactivo al modo
    final cardBg = isDark ? const Color(0xFF26203A) : Colors.white;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -2 && !_revealed) _open();
        if (details.delta.dx > 2 && _revealed)   _close();
      },
      onTap: _revealed ? _close : null,
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        height: 76,
        child: Stack(
          children: [
            // ── Botones de fondo ──────────────────────────────
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _handleEdit,
                      child: Container(
                        width: 72,
                        color: const Color.fromARGB(255, 49, 97, 243),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit_outlined, color: Colors.white, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              locale.t('edit'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _confirmDelete,
                      child: Container(
                        width: 72,
                        color: Colors.redAccent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              locale.t('delete'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tarjeta deslizable ────────────────────────────
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_animation.value, 0),
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                      child: Icon(
                        isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.transaction.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)
                                  ?? AppColors.textSecondary.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$amountSign${widget.transaction.amount.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
