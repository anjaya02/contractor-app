String? validateSid(String? value) {
  final sid = value?.trim() ?? '';
  if (sid.isEmpty) return 'Enter your service ID.';
  // The backend has not confirmed a fixed SID length; enforce digits only.
  if (!RegExp(r'^[0-9]+$').hasMatch(sid)) {
    return 'Use numbers only for your service ID.';
  }
  return null;
}
