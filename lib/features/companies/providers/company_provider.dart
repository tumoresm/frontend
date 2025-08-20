import 'package:fieldforce/apis/company_api.dart';
import 'package:fieldforce/apis/repcomp_api.dart';
import 'package:fieldforce/core/utils.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/companies/model/company_model.dart';
import 'package:fieldforce/features/companies/model/product_model.dart';
import 'package:fieldforce/features/companies/model/rep_company_relation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to get all companies
final getCompaniesProvider = FutureProvider((ref) async {
  try {
    final companyController = ref.watch(companyControllerProvider.notifier);
    return await companyController.getCompanies();
  } catch (e) {
    Loggers.database.warning('Companies API not available (Appwrite auth issue): $e');
    Loggers.database.info('Returning empty companies list until migration to FastAPI is complete');
    return <CompanyModel>[];
  }
}, name: 'getCompaniesProvider');

// Provider to get a single company by its ID
final getCompanyByIdProvider = FutureProvider.family((ref, String id) async {
  try {
    final companyController = ref.watch(companyControllerProvider.notifier);
    return await companyController.getCompanyById(id);
  } catch (e) {
    Loggers.database.warning('Company by ID API not available (Appwrite auth issue): $e');
    Loggers.database.info('Returning empty company for ID $id until migration to FastAPI is complete');
    // Return a default empty company model
    return CompanyModel(
      id: id,
      companyName: 'Company Not Available',
      description: 'Company data temporarily unavailable',
      industryId: '',
      logoUrl: '',
      products: <String>[],
      commissionPerOrder: 0.0,
      isActive: false,
    );
  }
}, name: 'getCompanyByIdProvider');

// Provider to get products by company ID
final getProductsByCompanyProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, String companyId) async {
  try {
    // For now, return an empty list since we don't have a product API yet
    // TODO: Implement product API and controller
    return <ProductModel>[];
  } catch (e) {
    Loggers.database.warning('Products API not available (Appwrite auth issue): $e');
    Loggers.database.info('Returning empty products list for company $companyId until migration to FastAPI is complete');
    return <ProductModel>[];
  }
}, name: 'getProductsByCompanyProvider');

// Controller for company-related actions
final companyControllerProvider =
    StateNotifierProvider<CompanyController, bool>((ref) {
  return CompanyController(
    companyAPI: ref.watch(companyAPIProvider),
    repCompanyRelationAPI: ref.watch(repCompanyRelationAPIProvider),
    ref: ref,
  );
}, name: 'companyControllerProvider');

class CompanyController extends StateNotifier<bool> {
  final ICompanyAPI _companyAPI;
  final IRepCompanyRelationAPI _repCompanyRelationAPI;
  final Ref _ref;

  CompanyController({
    required ICompanyAPI companyAPI,
    required IRepCompanyRelationAPI repCompanyRelationAPI,
    required Ref ref,
  })  : _companyAPI = companyAPI,
        _repCompanyRelationAPI = repCompanyRelationAPI,
        _ref = ref,
        super(false); // 'false' represents not loading

  Future<List<CompanyModel>> getCompanies() async {
    try {
      final res = await _companyAPI.getCompanies();
      return res.fold(
        (l) {
          Loggers.database.warning('Failed to get companies: ${l.message}');
          return <CompanyModel>[];
        },
        (r) => r.map((doc) => CompanyModel.fromMap(doc.data)).toList(),
      );
    } catch (e) {
      Loggers.database.error('Error in getCompanies: $e');
      return <CompanyModel>[];
    }
  }

  Future<CompanyModel> getCompanyById(String id) async {
    try {
      final res = await _companyAPI.getCompanyById(id);
      return res.fold(
        (l) {
          Loggers.database.warning('Failed to get company by ID $id: ${l.message}');
          // Return a default company model instead of throwing
          return CompanyModel(
            id: id,
            companyName: 'Company Not Available',
            description: 'Company data temporarily unavailable',
            industryId: '',
            logoUrl: '',
            products: <String>[],
            commissionPerOrder: 0.0,
            isActive: false,
          );
        },
        (r) => CompanyModel.fromMap(r.data),
      );
    } catch (e) {
      Loggers.database.error('Error in getCompanyById: $e');
      // Return a default company model instead of throwing
      return CompanyModel(
        id: id,
        companyName: 'Company Not Available',
        description: 'Company data temporarily unavailable',
        industryId: '',
        logoUrl: '',
        products: <String>[],
        commissionPerOrder: 0.0,
        isActive: false,
      );
    }
  }

  void addCompanyToProfile({
    required String companyId,
    required BuildContext context,
  }) async {
    state = true;
    try {
      final user = _ref.read(currentUserProvider).value;
      if (user == null) {
        state = false;
        if (context.mounted) {
          showSnackBar(context, 'User not logged in.');
        }
        return;
      }

      final relation = RepCompanyRelation(
        id: '', // Let backend/database assign ID
        userId: user['userId'] ?? '',
        companyId: companyId,
        dateAdded: DateTime.now(),
        verificationStatus: VerificationStatus.pending,
      );

      final res = await _repCompanyRelationAPI.addRelation(relation);
      state = false;
      res.fold(
        (l) {
          if (context.mounted) {
            showSnackBar(context, l.message);
          }
        },
        (r) {
          if (context.mounted) {
            showSnackBar(context, 'Application sent. Awaiting verification.');
            Navigator.pop(context); // Pop the bottom sheet
          }
        },
      );
    } catch (e) {
      state = false;
      Loggers.database.error('Error in addCompanyToProfile: $e');
      if (context.mounted) {
        showSnackBar(context, 'Failed to add company to profile. Please try again.');
      }
    }
  }
}
