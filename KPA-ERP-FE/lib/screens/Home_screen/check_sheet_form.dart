import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
// FIX: Removed Provider dependency as this widget will now manage its own state.
// import 'package:kpa_erp/provider/cheek_sheet_provider.dart';
// import 'package:provider/provider.dart';
import 'package:kpa_erp/widgets/custom_dropdown.dart';
import 'package:kpa_erp/widgets/custom_search_bar.dart';
import 'package:kpa_erp/widgets/custom_text_field.dart';
// You will need an ApiService import to submit the data
import 'package:kpa_erp/services/api_services/api_service.dart';


// FIX: Simplified the widget structure, removing the ChangeNotifierProvider.
class ChecksheetFormScreen extends StatefulWidget {
  const ChecksheetFormScreen({super.key});

  @override
  State<ChecksheetFormScreen> createState() => _ChecksheetFormScreenState();
}

class _ChecksheetFormScreenState extends State<ChecksheetFormScreen> {
  // --- State Management ---
  bool _isLoading = false;
  bool _isSubmitted = false;
  bool _isEditing = false;
  
  // --- Text Field Controllers ---
  final _searchController = TextEditingController();
  final _bogieNoController = TextEditingController();
  final _makerYearBuiltController = TextEditingController();
  final _incomingDivDateController = TextEditingController();
  final _deficitComponentsController = TextEditingController();
  final _dateOfIohController = TextEditingController();

  // --- Dropdown State Variables ---
  String _bogieFrameCondition = "Good";
  String _bolster = "Good";
  String _bolsterSuspensionBracket = "Good";
  String _lowerSpringSeat = "Good";
  String _axleGuide = "Good";
  String _axleGuideAssembly = "Good";
  String _protectiveTubes = "Good";
  String _anchorLinks = "Good";
  String _sideBearer = "Good";
  String _cylinderBodyDomeCover = "GOOD";
  String _pistonTrunnionBody = "GOOD";
  String _adjustingTubeScrew = "GOOD";
  String _plungerSpring = "GOOD";
  String _teeBoltHexNut = "GOOD";
  String _pawlAndPawlSpring = "GOOD";
  String _dustExcluder = "GOOD";
  
  @override
  void dispose() {
    _bogieNoController.dispose();
    _makerYearBuiltController.dispose();
    _incomingDivDateController.dispose();
    _deficitComponentsController.dispose();
    _dateOfIohController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    
    // Create the payload from controllers and state variables
    final payload = {
      "bogieNo": _bogieNoController.text,
      "makerYearBuilt": _makerYearBuiltController.text,
      "incomingDivDate": _incomingDivDateController.text,
      "deficitComponents": _deficitComponentsController.text,
      "dateOfIoh": _dateOfIohController.text,
      "bogieFrameCondition": _bogieFrameCondition,
      "bolster": _bolster,
      "bolsterSuspensionBracket": _bolsterSuspensionBracket,
      "lowerSpringSeat": _lowerSpringSeat,
      "axleGuide": _axleGuide,
      "axleGuideAssembly": _axleGuideAssembly,
      "protectiveTubes": _protectiveTubes,
      "anchorLinks": _anchorLinks,
      "sideBearer": _sideBearer,
      "cylinderBodyDomeCover": _cylinderBodyDomeCover,
      "pistonTrunnionBody": _pistonTrunnionBody,
      "adjustingTubeScrew": _adjustingTubeScrew,
      "plungerSpring": _plungerSpring,
      "teeBoltHexNut": _teeBoltHexNut,
      "pawlAndPawlSpring": _pawlAndPawlSpring,
      "dustExcluder": _dustExcluder,
    };

    try {
      // Replace with your actual API endpoint
      await ApiService.post('/api/forms/bogie-checksheet', payload);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checksheet submitted successfully!"), backgroundColor: Colors.green,));
        setState(() {
          _isSubmitted = true;
          _isEditing = false;
        });
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red,));
      }
    } finally {
      if(mounted) {
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

  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
        title: const Text("ICF Bogie Checksheet",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSubmitted && !_isEditing)
                _buildSummaryCard()
              else
                ..._buildFormFields(),
              
              const Gap(20),

              if (!_isSubmitted || _isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSubmit,
                    icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                        : const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text("Submit", style: TextStyle(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    const sectionSpacing = Gap(12);
    return [
      CustomSearchBar(
        hintText: "Search fields...",
        controller: _searchController,
        onChanged: (value) { /* Add search logic if needed */ },
      ),
      const Gap(16),
      const Text("Bogie Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      sectionSpacing,
      CustomTextField(
        label: "Bogie No.",
        controller: _bogieNoController,
        keyboardType: TextInputType.number,
      ),
      sectionSpacing,
      CustomTextField(
        label: "Maker & Year Built",
        controller: _makerYearBuiltController,
      ),
      sectionSpacing,
      GestureDetector(
        onTap: () => _pickDate(context, _incomingDivDateController),
        child: AbsorbPointer(
          child: TextField(
            controller: _incomingDivDateController,
            decoration: _dateDecoration("Incoming Div. & Date"),
          ),
        ),
      ),
      sectionSpacing,
      CustomTextField(
        label: "Deficit of component (if any)",
        controller: _deficitComponentsController,
      ),
      sectionSpacing,
      GestureDetector(
        onTap: () => _pickDate(context, _dateOfIohController),
        child: AbsorbPointer(
          child: TextField(
            controller: _dateOfIohController,
            decoration: _dateDecoration("Date of IOH"),
          ),
        ),
      ),
      const Divider(height: 32),
      const Text("Bogie Checksheet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Bogie Frame Condition",
        items: const ["Overaged", "Cracked", "Worn out", "Good"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _bogieFrameCondition = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Bolster",
        items: const ["Cracked", "Bent", "Good"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _bolster = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Bolster Suspension Bracket",
        items: const ["Cracked", "Corroded", "Good"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _bolsterSuspensionBracket = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Lower Spring Seat",
        items: const ["Cracked", "Worn out", "Good"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _lowerSpringSeat = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Axle Guide",
        items: const ["Worn", "Misalign", "Good"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _axleGuide = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Axle Guide Assembly",
        items: const ["Worn out", "Damaged", "Good"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _axleGuideAssembly = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Protective Tubes",
        items: const ["Cracked", "Good"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _protectiveTubes = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Anchor Links",
        items: const ["Damaged", "Good"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _anchorLinks = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Side Bearer",
        items: const ["Damaged", "Good"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _sideBearer = value),
      ),
      const Divider(height: 32),
      const Text("BMBC Checksheet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Cylinder Body & Dome Cover",
        items: const ["GOOD", "WORN OUT", "DAMAGED"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _cylinderBodyDomeCover = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Piston & Trunnion Body",
        items: const ["GOOD", "WORN OUT", "DAMAGED"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _pistonTrunnionBody = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Adjusting Tube and Screw",
        items: const ["GOOD", "WORN OUT", "DAMAGED"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _adjustingTubeScrew = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Plunger Spring",
        items: const ["GOOD", "WORN OUT", "DAMAGED"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _plungerSpring = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Tee Bolt, Hex Nut",
        items: const ["GOOD", "WORN OUT", "DAMAGED"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _teeBoltHexNut = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Pawl and Pawl Spring",
        items: const ["GOOD", "WORN OUT", "DAMAGED"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _pawlAndPawlSpring = value),
      ),
      sectionSpacing,
      CustomDropdownWithOther(
        label: "Dust Excluder",
        items: const ["GOOD", "WORN OUT", "DAMAGED"],
        enableColoredDropdown: true,
        onSaved: (value) => setState(() => _dustExcluder = value),
      ),
    ];
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.only(top: 24),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text("Submitted Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: _handleEdit,
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  tooltip: 'Edit',
                ),
              ],
            ),
            const Divider(),
            _summaryRow("Bogie No.", _bogieNoController.text),
            _summaryRow("Maker & Year Built", _makerYearBuiltController.text),
            _summaryRow("Bogie Frame Condition", _bogieFrameCondition),
            // Add all other fields to the summary card here
          ],
        ),
      ),
    );
  }

  InputDecoration _dateDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}
