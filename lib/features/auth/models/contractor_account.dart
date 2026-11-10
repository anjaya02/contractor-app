// Only fields used by the UI belong here. Map backend fields at the data boundary.
class ContractorAccount {
  const ContractorAccount({
    required this.sid,
    this.displayName,
    this.contractorName,
    this.userRole,
    this.rtom,
  });

  final String sid;
  final String? displayName;
  final String? contractorName;
  final String? userRole;
  final String? rtom;
}
