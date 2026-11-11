import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_theme.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../features/map/data/equipment_repository.dart';
import '../features/auth/data/login_repository.dart';
import '../features/auth/data/user_data_api.dart';
import '../features/auth/presentation/view_models/login_view_model.dart';
import 'session_gate.dart';

class ContractorApp extends StatelessWidget {
  const ContractorApp({
    super.key,
    this.loginRepository,
    this.equipmentRepository,
  });

  final LoginRepository? loginRepository;
  final EquipmentRepository? equipmentRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, client) => client.close(),
        ),
        Provider<LoginRepository>(
          create: (context) =>
              loginRepository ??
              ApiLoginRepository(
                api: UserDataApi(client: context.read<http.Client>()),
              ),
        ),
        Provider<EquipmentRepository>(
          create: (context) =>
              equipmentRepository ??
              ApiEquipmentRepository(
                api: ApiClient(client: context.read<http.Client>()),
              ),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (context) =>
            LoginViewModel(repository: context.read<LoginRepository>()),
        child: MaterialApp(
          title: AppConfig.name,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SessionGate(),
        ),
      ),
    );
  }
}
