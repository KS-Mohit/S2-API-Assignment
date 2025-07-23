import 'package:flutter/material.dart';
import 'package:kpa_erp/services/train_service_signup.dart';
// FIX: Removed the import for the non-existent model file.
// import 'package:kpa_erp/types/zone_division_type.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class ZoneDropdown extends StatefulWidget {
  final void Function(String) onSaved;
  final String? initialValue;

  const ZoneDropdown({
    Key? key,
    required this.onSaved,
    this.initialValue,
  }) : super(key: key);

  @override
  _ZoneDropdownState createState() => _ZoneDropdownState();
}

class _ZoneDropdownState extends State<ZoneDropdown> {
  String _selectedZone = '';
  // FIX: Changed all instances of 'ZoneDivision' to 'String'
  List<String> zoneList = [];
  List<DropdownItem<String>> zoneItems = [];
  final controller = MultiSelectController<String>();
  bool _isSelectingAll = false;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  @override
  void didUpdateWidget(ZoneDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _applyInitialValue();
    }
  }

  Future<void> _loadZones() async {
    try {
      // FIX: The service now correctly returns a List<String>.
      List<String> zones = await TrainServiceSignup.getZones();

      setState(() {
        zoneList = zones;
        // FIX: Map the list of strings directly to DropdownItem<String>.
        zoneItems = zones
            .map(
              (zoneCode) => DropdownItem<String>(
                label: zoneCode,
                value: zoneCode, // The value is the string itself.
              ),
            )
            .toList()
          ..sort((a, b) => a.label.compareTo(b.label));

        // Add the 'Select All' option. Use a unique value that won't conflict with real zone codes.
        // FIX: Removed 'const' because the DropdownItem constructor is not a const constructor.
        zoneItems.insert(0,
            DropdownItem<String>(
              label: 'All',
              value: 'SELECT_ALL_ZONES_VALUE', // A unique identifier for 'Select All'
            ));

        controller.setItems(zoneItems);
        _applyInitialValue();
      });
    } catch (e) {
      print("Error fetching zones: $e");
    }
  }

  void _applyInitialValue() {
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      final initialZones = widget.initialValue!.split(',');
      // FIX: Select items where the value (the string itself) is in the initial list.
      controller.selectWhere((item) => initialZones.contains(item.value));
      _selectedZone = widget.initialValue!;
    } else {
      controller.clearAll();
      _selectedZone = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiDropdown<String>(
      items: zoneItems,
      controller: controller,
      enabled: zoneItems.isNotEmpty,
      searchEnabled: true,
      chipDecoration: ChipDecoration(
        backgroundColor: Colors.white,
        border: Border.all(
          color: Colors.blue.shade300,
          width: 1.0,
        ),
      ),
      fieldDecoration: FieldDecoration(
        hintText: 'Zone',
        labelText: 'Zone *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dropdownDecoration: const DropdownDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      dropdownItemDecoration: const DropdownItemDecoration(
        selectedIcon: Icon(Icons.check_box, color: Colors.green),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select at least one zone';
        }
        return null;
      },
      onSelectionChange: (selectedItems) {
        final selectedSet = Set<String>.from(selectedItems);
        final isSelectAllNowSelected = selectedSet.contains('SELECT_ALL_ZONES_VALUE');
        
        // Handle 'Select All' logic
        if (isSelectAllNowSelected && !_isSelectingAll) {
          _isSelectingAll = true;
          // Select all items except the 'Select All' item itself
          controller.selectWhere((item) => item.value != 'SELECT_ALL_ZONES_VALUE');
          return;
        }

        // Handle 'Deselect All' logic
        if (!isSelectAllNowSelected && _isSelectingAll) {
          _isSelectingAll = false;
          controller.clearAll();
          return;
        }

        // Update the state with the selected zone codes
        setState(() {
          _selectedZone = selectedSet
              .where((item) => item != 'SELECT_ALL_ZONES_VALUE')
              .join(',');
        });

        widget.onSaved(_selectedZone);
      },
    );
  }
}
