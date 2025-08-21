import 'dart:convert';
import 'package:fieldforce/constants/api_constants.dart';
import 'package:fieldforce/core/failure.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/core/type_defs.dart';
import 'package:fieldforce/features/company/model/industry_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

abstract class IIndustryAPI {
  FutureEither<List<IndustryModel>> getIndustries();
}

class IndustryAPI implements IIndustryAPI {
  final String baseUrl;

  IndustryAPI({required this.baseUrl});

  @override
  FutureEither<List<IndustryModel>> getIndustries() async {
    try {
      final endpoint = '$baseUrl/industries';
      Loggers.database.info('Fetching industries from: $endpoint');
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      Loggers.database.debug('Industries API response status: ${response.statusCode}');
      Loggers.database.debug('Industries API response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle different response formats
        List<dynamic> industriesData;
        
        if (responseData is List) {
          // Direct array response: [...]
          industriesData = responseData;
          Loggers.database.info('Received direct array response with ${industriesData.length} industries');
        } else if (responseData is Map<String, dynamic>) {
          // Wrapped response: {"data": [...]} or {"success": true, "data": [...]}
          if (responseData.containsKey('data')) {
            final data = responseData['data'];
            if (data is List) {
              industriesData = data;
              Loggers.database.info('Received wrapped response with ${industriesData.length} industries');
            } else {
              Loggers.database.error('Data field is not a list: ${data.runtimeType}');
              return left(Failure(
                'Invalid response format: data field is not a list',
                StackTrace.current,
              ));
            }
          } else if (responseData.containsKey('industries')) {
            final data = responseData['industries'];
            if (data is List) {
              industriesData = data;
              Loggers.database.info('Received industries field with ${industriesData.length} industries');
            } else {
              Loggers.database.error('Industries field is not a list: ${data.runtimeType}');
              return left(Failure(
                'Invalid response format: industries field is not a list',
                StackTrace.current,
              ));
            }
          } else {
            // Try to extract any array from the response
            final possibleArrays = responseData.values.where((value) => value is List).toList();
            if (possibleArrays.isNotEmpty) {
              industriesData = possibleArrays.first as List<dynamic>;
              Loggers.database.info('Found array in response with ${industriesData.length} items');
            } else {
              Loggers.database.error('No array found in response: $responseData');
              return left(Failure(
                'Invalid response format: no array found in response',
                StackTrace.current,
              ));
            }
          }
        } else {
          Loggers.database.error('Unexpected response type: ${responseData.runtimeType}');
          return left(Failure(
            'Invalid response format: expected array or object',
            StackTrace.current,
          ));
        }
        
        // Convert to IndustryModel objects
        try {
          final industries = industriesData
              .map((item) {
                if (item is Map<String, dynamic>) {
                  return IndustryModel.fromMap(item);
                } else {
                  Loggers.database.warning('Skipping invalid industry item: $item');
                  return null;
                }
              })
              .whereType<IndustryModel>()
              .toList();
          
          Loggers.database.info('Successfully parsed ${industries.length} industries');
          return right(industries);
        } catch (e, stackTrace) {
          Loggers.database.error('Error parsing industries: $e');
          return left(Failure(
            'Failed to parse industries: $e',
            stackTrace,
          ));
        }
      } else {
        final errorMessage = 'Failed to load industries: HTTP ${response.statusCode}';
        Loggers.database.error('$errorMessage - Response: ${response.body}');
        return left(Failure(errorMessage, StackTrace.current));
      }
    } catch (e, stackTrace) {
      Loggers.database.error('Error fetching industries: $e');
      String userFriendlyMessage = 'Failed to load industries. ';
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        userFriendlyMessage += 'Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        userFriendlyMessage += 'Request timed out. Please try again.';
      } else {
        userFriendlyMessage += 'Please try again later.';
      }
      return left(Failure(userFriendlyMessage, stackTrace));
    }
  }
}

/// Riverpod provider for IndustryAPI
final industryAPIProvider = Provider<IIndustryAPI>((ref) {
  return IndustryAPI(baseUrl: ApiConstants.baseUrl);
});
