import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/locale_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/transaction_card.dart';
import 'transaction_form_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).loadTransactions();
    });
  }

  Future<void> _refreshData() async {
    await Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).loadTransactions();
  }

  void _openForm({TransactionModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionFormSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final txProvider   = Provider.of<TransactionProvider>(context);
    final locale       = Provider.of<LocaleProvider>(context);
    final theme        = Theme.of(context);
    final isDark       = theme.brightness == Brightness.dark;

    final user         = authProvider.currentUser;
    final userId       = user?.id ?? '';

    final totalIncome  = txProvider.getTotalIncome(userId);
    final totalExpense = txProvider.getTotalExpense(userId);
    final totalBalance = txProvider.getTotalBalance(userId);
    final transactions = txProvider.getUserTransactions(userId);

    // Colores del banner de balance reactivos al modo
    final bannerBg    = isDark ? const Color(0xFF26203A) : AppColors.primary;
    final subtileBg   = isDark ? const Color(0xFF2E2845) : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: subtileBg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF26203A) : AppColors.primary,
        elevation: 0,
        title: Text(
          locale.t('app_title'),
          style: TextStyle(
            color: isDark ? theme.textTheme.titleLarge?.color : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? theme.iconTheme.color : Colors.white,
        ),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ─── Banner de balance ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: BoxDecoration(color: bannerBg),
                child: Column(
                  children: [
                    Text(
                      locale.t('total_balance'),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$ ${_formatAmount(totalBalance)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryTile(
                            icon: Icons.arrow_upward_rounded,
                            label: locale.t('income_label'),
                            amount: '\$ ${_formatAmount(totalIncome)}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryTile(
                            icon: Icons.arrow_downward_rounded,
                            label: locale.t('expense_label'),
                            amount: '\$ ${_formatAmount(totalExpense)}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─── Lista de transacciones ───
              if (txProvider.isLoading && transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else if (transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Text(
                    locale.t('no_movements'),
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color ?? AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return TransactionCard(
                      transaction: tx,
                      onEdit: () => _openForm(existing: tx),
                      onDelete: () async {
                        try {
                          await Provider.of<TransactionProvider>(
                            context,
                            listen: false,
                          ).deleteTransaction(tx.id!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(locale.t('snack_deleted')),
                                  ],
                                ),
                                backgroundColor: AppColors.snackbarSuccess,
                              ),
                            );
                          }
                        } catch (_) {}
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          locale.t('add_movement'),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncate()) return amount.toInt().toString();
    return amount.toString();
  }
}
