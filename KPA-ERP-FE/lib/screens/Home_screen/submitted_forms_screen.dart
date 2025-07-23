// FIX: Corrected the import path from 'package.' to 'package:'. This fixes the core issue.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kpa_erp/models/submitted_form_model.dart';
import 'package:kpa_erp/services/api_services/api_service.dart';

class SubmittedFormsScreen extends StatefulWidget {
  const SubmittedFormsScreen({super.key});

  @override
  State<SubmittedFormsScreen> createState() => _SubmittedFormsScreenState();
}

class _SubmittedFormsScreenState extends State<SubmittedFormsScreen> {
  List<SubmittedForm> _allForms = [];
  List<SubmittedForm> _filteredForms = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchForms();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchForms() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/api/forms/all');
      if (response['data'] is List) {
        final List<SubmittedForm> forms = (response['data'] as List)
            .map((json) => SubmittedForm.fromJson(json))
            .toList();
        
        setState(() {
          _allForms = forms;
          _filteredForms = forms;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching forms: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    List<SubmittedForm> tempForms = List.from(_allForms);

    if (_searchController.text.isNotEmpty) {
      tempForms = tempForms.where((form) {
        return form.formNumber.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }

    if (_startDate != null) {
      tempForms = tempForms.where((form) {
        return form.submittedDate.isAfter(_startDate!.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (_endDate != null) {
      tempForms = tempForms.where((form) {
        return form.submittedDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _filteredForms = tempForms;
    });
  }
  
  Future<void> _pickDateRange() async {
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null 
          ? DateTimeRange(start: _startDate!, end: _endDate!) 
          : null,
    );

    if (newDateRange != null) {
      setState(() {
        _startDate = newDateRange.start;
        _endDate = newDateRange.end;
      });
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
      _filteredForms = _allForms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submitted Forms'),
         flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredForms.isEmpty
                    ? const Center(child: Text('No forms found.'))
                    : ListView.builder(
                        itemCount: _filteredForms.length,
                        itemBuilder: (context, index) {
                          final form = _filteredForms[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.description),
                              title: Text(form.formNumber),
                              subtitle: Text(
                                  'By ${form.submittedBy} on ${DateFormat('yyyy-MM-dd').format(form.submittedDate)}'),
                              trailing: Text(form.formType),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by Form Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Filter by Date'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                tooltip: 'Clear Filters',
              ),
            ],
          ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Filtering from ${DateFormat('dd MMM yyyy').format(_startDate!)} to ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                style: const TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
              ),
            )
        ],
      ),
    );
  }
}
