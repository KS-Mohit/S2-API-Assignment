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
  List<SubmittedForm> _forms = [];
  bool _isLoading = true;
  String? _error;

  // Controllers for each search field
  final TextEditingController _formNumberController = TextEditingController();
  final TextEditingController _inspectorController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchForms(); // Fetch initial data
    // Add listeners to trigger a refetch when the user types
    _formNumberController.addListener(_fetchForms);
    _inspectorController.addListener(_fetchForms);
  }

  @override
  void dispose() {
    _formNumberController.dispose();
    _inspectorController.dispose();
    super.dispose();
  }

  Future<void> _fetchForms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Build the query parameters map with specific keys
      final Map<String, String> queryParams = {};
      if (_formNumberController.text.isNotEmpty) {
        queryParams['formNumber'] = _formNumberController.text;
      }
      if (_inspectorController.text.isNotEmpty) {
        queryParams['inspector'] = _inspectorController.text;
      }
      if (_startDate != null) {
        queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(_startDate!);
      }
      if (_endDate != null) {
        queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(_endDate!);
      }

      final response = await ApiService.get('/api/forms/all', queryParams: queryParams);
      
      if (response['data'] is List) {
        final List<SubmittedForm> forms = (response['data'] as List)
            .map((json) => SubmittedForm.fromJson(json))
            .toList();
        
        setState(() {
          _forms = forms;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching forms: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDateRange() async {
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _startDate != null && _endDate != null 
          ? DateTimeRange(start: _startDate!, end: _endDate!) 
          : null,
    );

    if (newDateRange != null) {
      setState(() {
        _startDate = newDateRange.start;
        _endDate = newDateRange.end;
      });
      _fetchForms();
    }
  }

  void _clearFilters() {
    setState(() {
      _formNumberController.clear();
      _inspectorController.clear();
      _startDate = null;
      _endDate = null;
    });
    // The listeners will automatically trigger _fetchForms
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
                : _forms.isEmpty
                    ? Center(child: Text(_error ?? 'No forms found for the selected criteria.'))
                    : RefreshIndicator(
                        onRefresh: _fetchForms,
                        child: ListView.builder(
                          itemCount: _forms.length,
                          itemBuilder: (context, index) {
                            final form = _forms[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: form.formType == "Wheel Spec" ? Colors.blue.shade100 : Colors.green.shade100,
                                  child: Icon(
                                    form.formType == "Wheel Spec" ? Icons.album : Icons.build_circle,
                                    color: form.formType == "Wheel Spec" ? Colors.blue.shade800 : Colors.green.shade800,
                                  ),
                                ),
                                title: Text(form.formNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    'By ${form.submittedBy} on ${DateFormat('dd MMM, yyyy').format(form.submittedDate)}'),
                                trailing: Text(form.formType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                            );
                          },
                        ),
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
          // This is the TextField for the Form Number
          TextField(
            controller: _formNumberController,
            decoration: InputDecoration(
              labelText: 'Search by Form Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          // This is the TextField for the Inspector
          TextField(
            controller: _inspectorController,
            decoration: InputDecoration(
              labelText: 'Search by Inspector',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person_search),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Filter by Date'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              child: Chip(
                label: Text(
                  '${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}',
                ),
                onDeleted: _clearFilters,
                backgroundColor: Colors.blue.shade50,
              ),
            )
        ],
      ),
    );
  }
}
