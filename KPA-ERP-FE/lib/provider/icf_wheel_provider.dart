import 'package:flutter/material.dart';
class IcfWheelProvider extends ChangeNotifier {
  bool submitted = false;
  bool isEditing = false;
  bool showSummaryCard = false;
bool showFilterCard = false;  // for filter summary card

  final searchController = TextEditingController();
  final treadDiameterController = TextEditingController(text: "915 (900-1000)");
  final lastShopIssueController = TextEditingController(text: "837 (800-900)");
  final condemningDiaController = TextEditingController(text: "825 (800-900)");
  final wheelGaugeController = TextEditingController(text: "1600 (+2,-1)");

  final List<Map<String, Widget>> allFields = [];
  List<Map<String, Widget>> visibleFields = [];

  String filterFormNumber = '';
  String filterCreatedAt = '';
  String filterCreatedBy = '';

  void initializeFields(List<Map<String, Widget>> fields) {
    allFields.clear();
    allFields.addAll(fields);
    visibleFields = List.from(allFields);
    notifyListeners();
  }

  void filterFields(String query) {
    visibleFields = query.isEmpty
        ? List.from(allFields)
        : allFields
            .where((field) => field.keys.first.toLowerCase().contains(query.toLowerCase()))
            .toList();
    notifyListeners();
  }

  void applyFilter({String formNumber = '', String createdAt = '', String createdBy = ''}) {
    filterFormNumber = formNumber;
    filterCreatedAt = createdAt;
    filterCreatedBy = createdBy;

    // Example condition for demonstration, adjust logic according to your actual data
    showSummaryCard = formNumber.isNotEmpty || createdAt.isNotEmpty || createdBy.isNotEmpty;

    notifyListeners();
  }

  void handleSubmit(BuildContext context) {
    submitted = true;
    isEditing = false;
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Wheel spec form submitted successfully.")),
    );
  }

  void handleEdit() {
    isEditing = true;
    notifyListeners();
  }
}
