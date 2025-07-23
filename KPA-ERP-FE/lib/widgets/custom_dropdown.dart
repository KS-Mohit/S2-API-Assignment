import 'package:flutter/material.dart';

class CustomDropdownWithOther extends StatefulWidget {
  final String label;
  final List<String> items;
  final void Function(String value) onSaved;
  final String? initialValue;
  final bool enableColoredDropdown;

  const CustomDropdownWithOther({
    Key? key,
    required this.label,
    required this.items,
    required this.onSaved,
    this.initialValue,
    this.enableColoredDropdown = false,
  }) : super(key: key);

  @override
  _CustomDropdownWithOtherState createState() =>
      _CustomDropdownWithOtherState();
}

class _CustomDropdownWithOtherState extends State<CustomDropdownWithOther> {
  String? _selectedValue;
  bool _showOtherField = false;
  final TextEditingController _otherController = TextEditingController();
  late List<String> _allItems;

  @override
  void initState() {
    super.initState();
    
    _allItems = List<String>.from(widget.items);
    if (!_allItems.contains('Other')) {
      _allItems.add('Other');
    }

    // Set the initial value for the dropdown's internal state.
    _selectedValue = widget.initialValue ?? _allItems.first;
    
    // FIX: Do NOT call onSaved here. The parent widget already knows the initial value.
    // widget.onSaved(_selectedValue!); 

    _otherController.addListener(() {
      if (_showOtherField) {
        widget.onSaved(_otherController.text);
      }
    });
  }
  
  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  Color _getItemColor(String value) {
    if (!widget.enableColoredDropdown) {
      return Colors.black;
    }
    switch (value.toUpperCase()) {
      case 'OK':
      case 'GOOD':
        return Colors.green;
      case 'NOT OK':
      case 'WORN OUT':
      case 'DAMAGED':
      case 'CRACKED':
      case 'BENT':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedValue,
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
             enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          items: _allItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: _getItemColor(value)),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
              _showOtherField = newValue == 'Other';
              if (!_showOtherField) {
                widget.onSaved(newValue!);
              } else {
                 widget.onSaved(_otherController.text);
              }
            });
          },
          onSaved: (value) {
             if (_showOtherField) {
               widget.onSaved(_otherController.text);
             } else {
               widget.onSaved(value!);
             }
          },
        ),
        if (_showOtherField)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: TextFormField(
              controller: _otherController,
              decoration: InputDecoration(
                labelText: 'Please specify other value',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
