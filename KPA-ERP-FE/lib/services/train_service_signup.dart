import 'package:kpa_erp/services/api_services/api_service.dart';

// FIX: This service class is now self-contained and does not depend on external models.
// All methods consistently return a Future<List<String>>.
class TrainServiceSignup {
  
  // FIX: Changed the return type from List<ZoneDivision> to List<String>.
  // This removes the need for the missing 'zone_division_model.dart' file.
  static Future<List<String>> getZones() async {
    final response = await ApiService.get('/api/all_zones/');
    
    // Assuming the API returns a list of objects, each with a 'name' field.
    // Adjust the key 'name' if your API uses a different field for the zone name.
    if (response['data'] is List) {
      return (response['data'] as List)
          .map((item) => item['name'].toString())
          .toList();
    }
    return [];
  }

  // FIX: This method correctly returns a List<String> of division names.
  static Future<List<String>> getDivisions(String zone) async {
    final response = await ApiService.get('/api/divisions-of-zone/', queryParams: {'zone': zone});
    if (response['data'] is List) {
      // Assuming the API returns a direct list of strings.
      return List<String>.from(response['data']);
    }
    return [];
  }
  
  // FIX: This method correctly returns a List<String> of depot names.
  static Future<List<String>> getDepot(String division) async {
    final response = await ApiService.get('/api/depots-of-division/', queryParams: {'division': division});
     if (response['data'] is List) {
      return List<String>.from(response['data']);
    }
    return [];
  }

  // FIX: This method correctly returns a List<String> of train numbers.
  static Future<List<String>> getTrainList(String depot) async {
    final response = await ApiService.get('/api/trains-of-depo/', queryParams: {'depo': depot});
     if (response['data'] is List) {
      return List<String>.from(response['data']);
    }
    return [];
  }

  // FIX: This method correctly returns a List<String> of coach numbers.
  static Future<List<String>> getCoaches(String trainNumbers) async {
    final response = await ApiService.get('/api/coaches-of-train/', queryParams: {'trains': trainNumbers});
     if (response['data'] is List) {
      return List<String>.from(response['data']);
    }
    return [];
  }
}
