import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/loan_service.dart';

/// Reactively attaches/detaches Firestore sync based on auth state.
class PostAuthInitializer extends StatefulWidget {
  final Widget child;
  const PostAuthInitializer({super.key, required this.child});

  @override
  State<PostAuthInitializer> createState() => _PostAuthInitializerState();
}

class _PostAuthInitializerState extends State<PostAuthInitializer> {
  bool _attached = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final loanService = context.read<LoanService>();
        final shouldAttach = auth.isSignedIn && !auth.isGuest; // guest -> no remote

        if (shouldAttach && !_attached) {
          loanService.attachRemote(auth);
          _attached = true; // no setState needed: UI not dependent on this flag
        } else if (!shouldAttach && _attached) {
          loanService.detachRemote();
          _attached = false;
        }
        return widget.child;
      },
    );
  }
}
