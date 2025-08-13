import 'package:fieldforce/apis/company_api.dart';
import 'package:fieldforce/apis/repcomp_api.dart';
import 'package:fieldforce/core/utils.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/companies/model/company_model.dart';
import 'package:fieldforce/features/companies/model/product_model.dart';
import 'package:fieldforce/features/companies/model/rep_company_relation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to get all companies
final getCompaniesProvider = FutureProvider((ref) {
  final companyController = ref.watch(companyControllerProvider.notifier);
  return companyController.getCompanies();
});

// Provider to get a single company by its ID
final getCompanyByIdProvider = FutureProvider.family((ref, String id) {
  final companyController = ref.watch(companyControllerProvider.notifier);
  return companyController.getCompanyById(id);
});

// Provider to get products by company ID
final getProductsByCompanyProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, String companyId) async {
  // For now, return an empty list since we don't have a product API yet
  // TODO: Implement product API and controller
  return <ProductModel>[];
});

// Controller for company-related actions
final companyControllerProvider =
    StateNotifierProvider<CompanyController, bool>((ref) {
  return CompanyController(
    companyAPI: ref.watch(companyAPIProvider),
    repCompanyRelationAPI: ref.watch(repCompanyRelationAPIProvider),
    ref: ref,
  );
});

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
    final res = await _companyAPI.getCompanies();
    return res.fold(
      (l) => [],
      (r) => r.map((doc) => CompanyModel.fromMap(doc.data)).toList(),
    );
  }

  Future<CompanyModel> getCompanyById(String id) async {
    final res = await _companyAPI.getCompanyById(id);
    return res.fold(
      (l) => throw l,
      (r) => CompanyModel.fromMap(r.data),
    );
  }

  void addCompanyToProfile({
    required String companyId,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserProvider).value;
    if (user == null) {
      state = false;
      showSnackBar(context, 'User not logged in.');
      return;
    }

    final relation = RepCompanyRelation(
      id: '', // Let backend/database assign ID
      userId: user.$id,
      companyId: companyId,
      dateAdded: DateTime.now(),
      verificationStatus: VerificationStatus.pending,
    );

    final res = await _repCompanyRelationAPI.addRelation(relation);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Application sent. Awaiting verification.');
        Navigator.pop(context); // Pop the bottom sheet
      },
    );
  }
}
