import 'package:contractor_app/features/auth/data/login_repository.dart';
import 'package:contractor_app/features/auth/models/contractor_account.dart';

class FakeLoginRepository implements LoginRepository {
  Future<ContractorAccount> Function(String sid)? onSignIn;
  final submittedSids = <String>[];

  @override
  Future<ContractorAccount> signIn(String sid) async {
    submittedSids.add(sid);
    if (onSignIn case final handler?) return handler(sid);
    return ContractorAccount(sid: sid, displayName: 'Test Contractor');
  }
}
