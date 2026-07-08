final RegExp _riskPattern =
    RegExp(r'mold|aflatox|contamin|infect|positive', caseSensitive: false);
final RegExp _safePattern =
    RegExp(r'no mold|healthy|clean|safe|negative', caseSensitive: false);

// Falls back to keyword matching on the model's label text when no explicit
// boolean risk flag is present in the response (e.g. for scans already
// persisted to Firestore, which only store the label string).
bool isHighRiskLabel(String label) {
  return _riskPattern.hasMatch(label) && !_safePattern.hasMatch(label);
}
