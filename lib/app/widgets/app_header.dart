import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAddLoan;
  final VoidCallback? onRefresh;
  final bool showAdd;
  const AppHeader({super.key, this.onAddLoan, this.onRefresh, this.showAdd = true});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final currentRoute = ModalRoute.of(context)?.settings.name;

    Widget navButton(String label, String routeName) {
      final bool active = currentRoute == routeName || (routeName == AppRoutes.home && currentRoute == null);
      final text = Text(label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            decoration: active ? TextDecoration.underline : TextDecoration.none,
            decorationColor: Colors.white,
            decorationThickness: 2,
          ));
      return TextButton(
        onPressed: active ? null : () => Navigator.pushNamed(context, routeName),
        child: text,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0,2))],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Row(
            children: [
              const Icon(Icons.dashboard, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Installment Tracker', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold)),
              const Spacer(),
              navButton('Home', AppRoutes.home),
              navButton('About', AppRoutes.about),
              TextButton(
                onPressed: () => _showDonate(context),
                child: const Text('Donate', style: TextStyle(color: Colors.white)),
              ),
              if (showAdd) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  onPressed: onAddLoan,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Loan'),
                ),
              ],
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
              const SizedBox(width: 8),
              if (auth.isSignedIn || auth.isGuest)
                PopupMenuButton<String>(
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: const Icon(Icons.person, color: Colors.white,size:18),
                  ),
                  onSelected: (v) async {
                    if (v == 'signout') {
                      if (auth.isSignedIn) {
                        await auth.signOut();
                      } else {
                        // exit guest mode
                        await auth.signOut();
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem<String>(
                      value: 'email',
                      enabled: false,
                      child: Text(auth.displayEmail ?? 'guest', style: const TextStyle(fontSize: 12)),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'signout',
                      child: Row(
                        children: [Icon(Icons.logout, size:18), SizedBox(width:8), Text('Sign out')],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDonate(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Support the Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Thank you for considering a donation!'),
            SizedBox(height: 12),
            Text('Add your Buy Me a Coffee / Ko-fi / Stripe link here.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
