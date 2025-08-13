import 'dart:convert';
import 'package:fieldforce/constants/api_constants.dart';
import 'package:fieldforce/core/failure.dart';
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
      final response = await http.get(Uri.parse('$baseUrl/industries'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final industries = data.map((e) => IndustryModel.fromMap(e)).toList();
        return right(industries);
      } else {
        return left(Failure(
            'Failed to load industries: ${response.statusCode}',
            StackTrace.current));
      }
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}

/// Riverpod provider for IndustryAPI
final industryAPIProvider = Provider<IIndustryAPI>((ref) {
  return IndustryAPI(baseUrl: ApiConstants.baseUrl);
});
