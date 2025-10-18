
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/companies/model/company_model.dart';
import 'package:fieldforce/features/companies/model/product_model.dart';
import 'package:fieldforce/features/companies/model/rep_company_relation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

/// Provider for FastAPI company API
final fastapiCompanyAPIProvider = Provider<IFastAPICompanyAPI>((ref) {
  final httpClient = ref.watch(authenticatedHttpClientProvider);
  return FastAPICompanyAPI(httpClient);
});

/// Interface for company API operations
abstract class IFastAPICompanyAPI {
  /// Get all companies
  FutureEither<List<CompanyModel>> getCompanies({
    int? limit,
    int? offset,
    String? industryId,
    bool? isActive,
  });
  
  /// Get company by ID
  FutureEither<CompanyModel> getCompanyById(String id);
  
  /// Get products by company ID
  FutureEither<List<ProductModel>> getProductsByCompany(String companyId);
  
  /// Get user's company relations
  FutureEither<List<RepCompanyRelation>> getUserCompanyRelations();
  
  /// Add company relation (apply to represent a company)
  FutureEither<RepCompanyRelation> addCompanyRelation(RepCompanyRelation relation);
  
  /// Update company relation status
  FutureEither<RepCompanyRelation> updateCompanyRelation(String relationId, RepCompanyRelation relation);
  
  /// Remove company relation
  FutureEither<void> removeCompanyRelation(String relationId);
}

/// FastAPI implementation of company API
class FastAPICompanyAPI extends FastAPIRepository implements IFastAPICompanyAPI {
  FastAPICompanyAPI(super.httpClient);

  @override
  FutureEither<List<CompanyModel>> getCompanies({
    int? limit,
    int? offset,
    String? industryId,
    bool? isActive,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (industryId != null) queryParams['industry_id'] = industryId;
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final endpoint = '/companies${queryString.isNotEmpty ? '?$queryString' : ''}';
      final response = await httpClient.get(endpoint);
      
      final companies = handleListResponse<CompanyModel>(
        response,
        (data) => CompanyModel.fromMap(data),
        operation: 'Get companies',
      );
      
      Loggers.database.info('Retrieved ${companies.length} companies');
      return right(companies);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get companies: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<CompanyModel> getCompanyById(String id) async {
    try {
      final response = await httpClient.get('/companies/$id');
      
      final company = handleResponse<CompanyModel>(
        response,
        (data) => CompanyModel.fromMap(data),
        operation: 'Get company by ID',
      );
      
      Loggers.database.info('Company retrieved successfully: $id');
      return right(company);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get company by ID: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<List<ProductModel>> getProductsByCompany(String companyId) async {
    try {
      final response = await httpClient.get('/companies/$companyId/products');
      
      final products = handleListResponse<ProductModel>(
        response,
        (data) => ProductModel.fromMap(data),
        operation: 'Get products by company',
      );
      
      Loggers.database.info('Retrieved ${products.length} products for company: $companyId');
      return right(products);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get products by company: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<List<RepCompanyRelation>> getUserCompanyRelations() async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.get('/companies/relations/me');
      
      final relations = handleListResponse<RepCompanyRelation>(
        response,
        (data) => RepCompanyRelation.fromMap(data),
        operation: 'Get user company relations',
      );
      
      Loggers.database.info('Retrieved ${relations.length} company relations');
      return right(relations);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to get user company relations: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<RepCompanyRelation> addCompanyRelation(RepCompanyRelation relation) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final requestBody = relation.toMap();
      // Remove fields that should be set by the server
      requestBody.remove('id');
      requestBody.remove('userId');
      requestBody.remove('dateAdded');
      
      final response = await httpClient.post(
        '/companies/relations',
        body: requestBody,
      );
      
      final newRelation = handleResponse<RepCompanyRelation>(
        response,
        (data) => RepCompanyRelation.fromMap(data),
        operation: 'Add company relation',
      );
      
      Loggers.database.info('Company relation added successfully: ${newRelation.id}');
      return right(newRelation);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to add company relation: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<RepCompanyRelation> updateCompanyRelation(String relationId, RepCompanyRelation relation) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final requestBody = relation.toMap();
      // Remove fields that shouldn't be updated by user
      requestBody.remove('id');
      requestBody.remove('userId');
      requestBody.remove('dateAdded');
      
      final response = await httpClient.put(
        '/companies/relations/$relationId',
        body: requestBody,
      );
      
      final updatedRelation = handleResponse<RepCompanyRelation>(
        response,
        (data) => RepCompanyRelation.fromMap(data),
        operation: 'Update company relation',
      );
      
      Loggers.database.info('Company relation updated successfully: $relationId');
      return right(updatedRelation);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to update company relation: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<void> removeCompanyRelation(String relationId) async {
    try {
      await FastAPISecurity.ensureAuthenticated();
      
      final response = await httpClient.delete('/companies/relations/$relationId');
      
      handleVoidResponse(response, operation: 'Remove company relation');
      
      Loggers.database.info('Company relation removed successfully: $relationId');
      return right(null);
    } catch (e, stackTrace) {
      Loggers.database.error('Failed to remove company relation: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }
}