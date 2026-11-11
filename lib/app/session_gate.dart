import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/models/contractor_account.dart';
import '../features/auth/presentation/view_models/login_view_model.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';

class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) =>
      Selector<LoginViewModel, ContractorAccount?>(
        selector: (_, model) => model.state.account,
        builder: (context, account, _) => account == null
            ? const LoginScreen()
            : _WorkspaceNavigator(key: ValueKey(account), account: account),
      );
}

class _WorkspaceNavigator extends StatefulWidget {
  const _WorkspaceNavigator({super.key, required this.account});
  final ContractorAccount account;

  @override
  State<_WorkspaceNavigator> createState() => _WorkspaceNavigatorState();
}

class _WorkspaceNavigatorState extends State<_WorkspaceNavigator> {
  final _navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => NavigatorPopHandler<Object?>(
    onPopWithResult: (result) => _navigator.currentState?.pop(result),
    // Removing the signed-in workspace also removes all of its open routes.
    child: Navigator(
      key: _navigator,
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => HomeScreen(account: widget.account),
      ),
    ),
  );
}
