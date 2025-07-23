import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kpa_erp/services/api_services/api_service.dart';
import 'package:kpa_erp/widgets/custom_dropdown.dart';
import 'package:kpa_erp/widgets/custom_search_bar.dart';
import 'package:kpa_erp/widgets/custom_text_field.dart';

// Helper class to structure our form fields
class FormFieldData {
  final String label;
  final Widget widget;

  FormFieldData({required this.label, required this.widget});
}

class IcfWheelScreen extends StatefulWidget {
  const IcfWheelScreen({super.key});

  @override
  State<IcfWheelScreen> createState() => _IcfWheelScreenState();
}

class _IcfWheelScreenState extends State<IcfWheelScreen> {
  bool _isLoading = false;
  bool _isSubmitted = false;
  bool _isEditing = false;

  // --- Controllers for text fields ---
  final _searchController = TextEditingController();
  final _treadDiameterController = TextEditingController();
  final _lastShopIssueController = TextEditingController();
  final _condemningDiaController = TextEditingController();
  final _wheelGaugeController = TextEditingController();
  
  // --- State variables for dropdowns ---
  String _rollerBearingOuterDia = "280 (+0.0/-0.035)";
  String _rollerBearingBoreDia = "130 (+0.0/-0.025)";
  String _rollerBearingWidth = "93 (+0/-0.250)";
  String _axleBoxHousingBoreDia = "280 (+0.030/+0.052)";
  String _wheelDiscWidth = "127 (+4/-0)";

  // FIX: State variable to hold the search query
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Add a listener to the search controller to update the UI on text change
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _searchController.dispose();
    _treadDiameterController.dispose();
    _lastShopIssueController.dispose();
    _condemningDiaController.dispose();
    _wheelGaugeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    final payload = {
      "formNumber": "WHEEL-FORM-${DateTime.now().millisecondsSinceEpoch}",
      "submittedBy": "frontend_user",
      "submittedDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "fields": {
        "treadDiameterNew": _treadDiameterController.text,
        "lastShopIssueSize": _lastShopIssueController.text,
        "condemningDia": _condemningDiaController.text,
        "wheelGauge": _wheelGaugeController.text,
        "variationSameAxle": "0.5",
        "variationSameBogie": "5",
        "variationSameCoach": "13",
        "wheelProfile": "29.4 Flange Thickness",
        "intermediateWWP": "20 TO 28",
        "bearingSeatDiameter": "130.043 TO 130.068",
        "rollerBearingOuterDia": _rollerBearingOuterDia,
        "rollerBearingBoreDia": _rollerBearingBoreDia,
        "rollerBearingWidth": _rollerBearingWidth,
        "axleBoxHousingBoreDia": _axleBoxHousingBoreDia,
        "wheelDiscWidth": _wheelDiscWidth,
      }
    };

    try {
      await ApiService.post('/api/forms/wheel-specifications', payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Form submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isSubmitted = true;
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleEdit() {
    setState(() {
      _isSubmitted = false;
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "ICF Wheel Specs",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isSubmitted && !_isEditing)
                _buildSummaryCard()
              else
                ..._buildFormFields(),
              
              const Gap(20),

              if (!_isSubmitted || _isEditing)
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSubmit,
                  icon: _isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    _isEditing ? "Update" : "Submit",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // This method now builds all the fields and handles the search filtering.
  List<Widget> _buildFormFields() {
    // Define all possible form fields in a structured list.
    final allFields = [
      FormFieldData(
        label: "Tread Diameter (New)",
        widget: CustomTextField(
          label: "Tread Diameter (New)",
          controller: _treadDiameterController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
      FormFieldData(
        label: "Last Shop Issue Size (Dia.)",
        widget: CustomTextField(
          label: "Last Shop Issue Size (Dia.)",
          controller: _lastShopIssueController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
      FormFieldData(
        label: "Condemning Dia.",
        widget: CustomTextField(
          label: "Condemning Dia.",
          controller: _condemningDiaController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
      FormFieldData(
        label: "Wheel Gauge (IFD)",
        widget: CustomTextField(
          label: "Wheel Gauge (IFD)",
          controller: _wheelGaugeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ),
      FormFieldData(
        label: "Permissible Variation - Same Axle",
        widget: const CustomTextField(
          label: "Permissible Variation - Same Axle",
          value: "0.5",
          readOnly: true,
        ),
      ),
      FormFieldData(
        label: "Permissible Variation - Same Bogie",
        widget: const CustomTextField(
          label: "Permissible Variation - Same Bogie",
          value: "5",
          readOnly: true,
        ),
      ),
      FormFieldData(
        label: "Permissible Variation - Same Coach",
        widget: const CustomTextField(
          label: "Permissible Variation - Same Coach",
          value: "13",
          readOnly: true,
        ),
      ),
      FormFieldData(
        label: "Wheel Profile (RDSO 91146 Alt.2)",
        widget: const CustomTextField(
          label: "Wheel Profile (RDSO 91146 Alt.2)",
          value: "29.4 Flange Thickness",
          readOnly: true,
        ),
      ),
      FormFieldData(
        label: "Intermediate WWP (RDSO 92082)",
        widget: const CustomTextField(
          label: "Intermediate WWP (RDSO 92082)",
          value: "20 TO 28",
          readOnly: true,
        ),
      ),
      FormFieldData(
        label: "Bearing Seat Diameter",
        widget: const CustomTextField(
          label: "Bearing Seat Diameter",
          value: "130.043 TO 130.068",
          readOnly: true,
        ),
      ),
      FormFieldData(
        label: "Roller Bearing Outer Dia",
        widget: CustomDropdownWithOther(
          label: "Roller Bearing Outer Dia",
          items: const ["280 (+0.0/-0.035)"],
          onSaved: (value) => setState(() => _rollerBearingOuterDia = value),
        ),
      ),
      FormFieldData(
        label: "Roller Bearing Bore Dia",
        widget: CustomDropdownWithOther(
          label: "Roller Bearing Bore Dia",
          items: const ["130 (+0.0/-0.025)"],
          onSaved: (value) => setState(() => _rollerBearingBoreDia = value),
        ),
      ),
      FormFieldData(
        label: "Roller Bearing Width",
        widget: CustomDropdownWithOther(
          label: "Roller Bearing Width",
          items: const ["93 (+0/-0.250)"],
          onSaved: (value) => setState(() => _rollerBearingWidth = value),
        ),
      ),
      FormFieldData(
        label: "Axle Box Housing Bore Dia",
        widget: CustomDropdownWithOther(
          label: "Axle Box Housing Bore Dia",
          items: const ["280 (+0.030/+0.052)"],
          onSaved: (value) => setState(() => _axleBoxHousingBoreDia = value),
        ),
      ),
      FormFieldData(
        label: "Wheel Disc Width",
        widget: CustomDropdownWithOther(
          label: "Wheel Disc Width",
          items: const [
            "127 (+4/-0)",
            "275 (+0.0/-0.030)",
            "285 (+0.0/-0.040)",
          ],
          onSaved: (value) => setState(() => _wheelDiscWidth = value),
        ),
      ),
    ];

    // Filter the fields based on the search query.
    final filteredFields = _searchQuery.isEmpty
        ? allFields
        : allFields.where((field) {
            return field.label.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    // Build the final list of widgets to display.
    return [
      CustomSearchBar(
        hintText: "Search fields...",
        controller: _searchController,
      ),
      const Gap(16),
      // Use a ListView.builder for performance with many fields, or a Column for fewer.
      ...filteredFields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: field.widget,
          )),
    ];
  }

  // FIX: Added the implementation for the summary card.
  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Submitted Data", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _handleEdit,
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  tooltip: 'Edit',
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            _summaryRow("Tread Diameter (New)", _treadDiameterController.text),
            _summaryRow("Last Shop Issue Size", _lastShopIssueController.text),
            _summaryRow("Condemning Dia.", _condemningDiaController.text),
            _summaryRow("Wheel Gauge (IFD)", _wheelGaugeController.text),
            // Add more rows here to display all the submitted data
          ],
        ),
      ),
    );
  }

  // FIX: Added the implementation for the summary row.
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
