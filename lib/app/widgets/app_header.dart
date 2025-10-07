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

  static const double _desktopBreakpoint = 720; // below this we compact

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final width = MediaQuery.of(context).size.width;
    final compact = width < _desktopBreakpoint;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderMedium, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Row(
            children: [
              // Logo + Title
              Row(
                children: [
                  CircleAvatar(
                    radius: compact ? 16 : 18,
                    backgroundColor: AppColors.primary.withOpacity(.15),
                    child: Icon(Icons.dashboard, color: AppColors.primary, size: compact ? 18 : 20),
                  ),
                  SizedBox(width: compact ? 8 : 12),
                  Text(
                    'Installment Tracker',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: compact ? 15 : 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (!compact) ...[
                _navButton(context, 'Home', AppRoutes.home, currentRoute),
                const SizedBox(width: 8),
                _navButton(context, 'About', AppRoutes.about, currentRoute),
                const SizedBox(width: 12),
                _textLink(context, 'Donate', () => _showDonate(context)),
                if (showAdd) ...[
                  const SizedBox(width: 12),
                  _addButton(),
                ],
                const SizedBox(width: 12),
                _refreshButton(),
                const SizedBox(width: 8),
                if (auth.isSignedIn || auth.isGuest) _profileMenu(auth),
              ] else ...[
                if (auth.isSignedIn || auth.isGuest) _profileMenu(auth, compact: true),
                PopupMenuButton<String>(
                  tooltip: 'Menu',
                  onSelected: (value) => _handleMenu(value, context),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'home', child: _menuRow(Icons.home_outlined, 'Home')),
                    PopupMenuItem(value: 'about', child: _menuRow(Icons.info_outline, 'About')),
                    if (showAdd) PopupMenuItem(value: 'add', child: _menuRow(Icons.add_circle_outline, 'Add Loan')),
                    PopupMenuItem(value: 'refresh', child: _menuRow(Icons.refresh, 'Refresh')),
                    PopupMenuItem(value: 'donate', child: _menuRow(Icons.favorite_outline, 'Donate')),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'signout',
                      child: _menuRow(Icons.logout, 'Sign out'),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 22, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, String label, String route, String? current) {
    final active = current == route || (route == AppRoutes.home && (current == null || current == '/'));
    return InkWell(
      onTap: active ? null : () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: active ? AppColors.primary.withOpacity(.12) : null,
          border: Border.all(
            color: active ? AppColors.primary.withOpacity(.5) : AppColors.borderMedium,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              route == AppRoutes.home ? Icons.home_outlined : Icons.info_outline,
              size: 16,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textLink(BuildContext context, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  Widget _addButton() => ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: onAddLoan,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Loan'),
      );

  Widget _refreshButton() => IconButton(
        tooltip: 'Refresh',
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
      );

  Widget _profileMenu(AuthService auth, {bool compact = false}) => PopupMenuButton<String>(
        tooltip: 'Account',
        icon: CircleAvatar(
          radius: compact ? 15 : 16,
          backgroundColor: AppColors.primary.withOpacity(.15),
          child: Icon(Icons.person, color: AppColors.primary, size: compact ? 16 : 18),
        ),
        onSelected: (v) async {
          if (v == 'signout') {
            await auth.signOut();
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
              children: [Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('Sign out')],
            ),
          ),
        ],
      );

  Widget _menuRow(IconData icon, String label) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      );

  void _handleMenu(String value, BuildContext context) {
    switch (value) {
      case 'home':
        if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
          Navigator.pushNamed(context, AppRoutes.home);
        }
        break;
      case 'about':
        if (ModalRoute.of(context)?.settings.name != AppRoutes.about) {
          Navigator.pushNamed(context, AppRoutes.about);
        }
        break;
      case 'add':
        onAddLoan?.call();
        break;
      case 'refresh':
        onRefresh?.call();
        break;
      case 'donate':
        _showDonate(context);
        break;
      case 'signout':
        context.read<AuthService>().signOut();
        break;
    }
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
