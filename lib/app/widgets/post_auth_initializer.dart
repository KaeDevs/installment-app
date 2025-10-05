import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/loan_service.dart';

/// Ensures remote repository is attached after auth.
class PostAuthInitializer extends StatefulWidget {
  final Widget child;
  const PostAuthInitializer({super.key, required this.child});

  @override
  State<PostAuthInitializer> createState() => _PostAuthInitializerState();
}

class _PostAuthInitializerState extends State<PostAuthInitializer> {
  bool _attached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attemptAttach();
  }

  void _attemptAttach() {
    if (_attached) return;
    final auth = context.read<AuthService>();
    if (!auth.isSignedIn) return;
    final loanService = context.read<LoanService>();
    loanService.attachRemote(auth);
    setState(() => _attached = true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
