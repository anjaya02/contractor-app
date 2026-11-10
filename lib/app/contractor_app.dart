import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_theme.dart';
import '../features/account/presentation/account_screen.dart';
import '../features/auth/data/login_repository.dart';
import '../features/auth/data/user_data_api.dart';
import '../features/auth/presentation/login_controller.dart';
import '../features/auth/presentation/login_screen.dart';

class ContractorApp extends StatefulWidget {
  const ContractorApp({super.key, this.loginRepository});

  final LoginRepository? loginRepository;

  @override
  State<ContractorApp> createState() => _ContractorAppState();
}

class _ContractorAppState extends State<ContractorApp> {
  http.Client? _client;
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    final LoginRepository repository;
    if (widget.loginRepository case final supplied?) {
      repository = supplied;
    } else {
      _client = http.Client();
      repository = ApiLoginRepository(api: UserDataApi(client: _client!));
    }
    _loginController = LoginController(repository: repository);
  }

  @override
  void dispose() {
    _loginController.dispose();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contractor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: ListenableBuilder(
        listenable: _loginController,
        builder: (context, _) {
          final account = _loginController.account;
          return account == null
              ? LoginScreen(controller: _loginController)
              : AccountScreen(
                  account: account,
                  onSignOut: _loginController.signOut,
                );
        },
      ),
    );
  }
}
