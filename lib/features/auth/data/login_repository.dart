import '../models/contractor_account.dart';
import 'user_data_api.dart';
import 'user_data_decoder.dart';

abstract class LoginRepository {
  Future<ContractorAccount> signIn(String sid);
}

class ApiLoginRepository implements LoginRepository {
  ApiLoginRepository({required UserDataApi api}) : _api = api;

  final UserDataApi _api;

  @override
  Future<ContractorAccount> signIn(String sid) async {
    final payload = await _api.getUserData(sid);
    return decodeUserData(payload, requestedSid: sid);
  }
}
