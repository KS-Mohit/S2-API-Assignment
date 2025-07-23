import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? value; // Made optional
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool readOnly; // Added readOnly property

  const CustomTextField({
    super.key,
    required this.label,
    this.value,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    // A controller and an initial value cannot be used at the same time.
    assert(controller == null || value == null,
        'Cannot provide both a controller and a value');

    return TextFormField(
      controller: controller,
      initialValue: value,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        // Visually indicate that the field is disabled when read-only
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}