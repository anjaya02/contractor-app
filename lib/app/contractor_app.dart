import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_theme.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/map/data/equipment_repository.dart';
import '../features/auth/data/login_repository.dart';
import '../features/auth/data/user_data_api.dart';
import '../features/auth/presentation/login_controller.dart';
import '../features/auth/presentation/login_screen.dart';

class ContractorApp extends StatefulWidget {
  const ContractorApp({
    super.key,
    this.loginRepository,
    this.equipmentRepository,
  });

  final LoginRepository? loginRepository;
  final EquipmentRepository? equipmentRepository;

  @override
  State<ContractorApp> createState() => _ContractorAppState();
}

class _ContractorAppState extends State<ContractorApp> {
  http.Client? _client;
  late final LoginController _loginController;
  late final EquipmentRepository _equipmentRepository;

  @override
  void initState() {
    super.initState();
    _client = http.Client();
    final LoginRepository repository;
    if (widget.loginRepository case final supplied?) {
      repository = supplied;
    } else {
      repository = ApiLoginRepository(api: UserDataApi(client: _client!));
    }
    _loginController = LoginController(repository: repository);
    _equipmentRepository =
        widget.equipmentRepository ??
        ApiEquipmentRepository(api: ApiClient(client: _client!));
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
      title: AppConfig.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: ListenableBuilder(
        listenable: _loginController,
        builder: (context, _) {
          final account = _loginController.account;
          return account == null
              ? LoginScreen(controller: _loginController)
              : HomeScreen(
                  account: account,
                  onSignOut: _loginController.signOut,
                  equipmentRepository: _equipmentRepository,
                );
        },
      ),
    );
  }
}
