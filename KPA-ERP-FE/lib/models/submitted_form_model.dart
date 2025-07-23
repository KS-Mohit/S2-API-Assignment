// This class defines the structure for a single submitted form record.
class SubmittedForm {
  final String formNumber;
  final String submittedBy;
  final DateTime submittedDate;
  final String formType; // e.g., "Wheel Spec" or "Bogie Checksheet"

  SubmittedForm({
    required this.formNumber,
    required this.submittedBy,
    required this.submittedDate,
    required this.formType,
  });

  // Factory constructor to create a SubmittedForm from a JSON object.
  // This is crucial for parsing the data from your API.
  factory SubmittedForm.fromJson(Map<String, dynamic> json) {
    return SubmittedForm(
      formNumber: json['formNumber'] ?? 'N/A',
      submittedBy: json['submittedBy'] ?? 'N/A',
      submittedDate: json['submittedDate'] != null
          ? DateTime.parse(json['submittedDate'])
          : DateTime.now(),
      formType: json['formType'] ?? 'Unknown Form',
    );
  }
}
