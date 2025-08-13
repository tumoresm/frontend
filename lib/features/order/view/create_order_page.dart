import 'package:fieldforce/core/utils.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/companies/model/company_model.dart';
import 'package:fieldforce/features/companies/model/product_model.dart';
import 'package:fieldforce/features/companies/providers/company_provider.dart';
import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:fieldforce/features/order/provider/order_provider.dart';
import 'package:fieldforce/utils/utilities.dart';

import 'package:flutter/material.dart' hide FlatButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateOrderPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const CreateOrderPage(),
      );
  const CreateOrderPage({super.key});

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerEmailController = TextEditingController();
  final customerAddressController = TextEditingController();
  final customerLocationController = TextEditingController();
  // Controllers for invoice calculation
  final productPriceController = TextEditingController();
  final shippingController = TextEditingController();
  final taxRateController = TextEditingController();

  CompanyModel? _selectedCompany;
  ProductModel? _selectedProduct;

  @override
  void dispose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerEmailController.dispose();
    customerAddressController.dispose();
    customerLocationController.dispose();
    productPriceController.dispose();
    shippingController.dispose();
    taxRateController.dispose();
    super.dispose();
  }

  void onSubmit(String userId) async {
    // Trigger form validation
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do not proceed
    }

    if (_selectedCompany == null) {
      showSnackBar(context, 'Please select a company');
      return;
    }

    if (_selectedProduct == null) {
      showSnackBar(context, 'Please select a product');
      return;
    }

    // Calculate the total invoice
    final invoiceTotal = calculateInvoiceTotal(
      productPrice: double.tryParse(productPriceController.text) ?? 0.0,
      shipping: double.tryParse(shippingController.text) ?? 0.0,
      taxRate: double.tryParse(taxRateController.text) ?? 0.0,
      // TODO: Add fields for addons and accessories if needed
    );

    try {
      ref.read(orderControllerProvider.notifier).createOrder(
            // The user's ID is used as the representative's ID for the order.
            repId: userId,
            companyId: _selectedCompany!.id,
            productId: _selectedProduct!.id,
            // Convert the calculated double to a string for the model
            invoiceTotal: invoiceTotal,
            customerName: customerNameController.text,
            customerPhone: customerPhoneController.text,
            customerEmail: customerEmailController.text,
            customerAddress: customerAddressController.text,
            customerLocation: {},
            // TODO: Implement location picker
            orderStatus: OrderStatus.pending, // Default status for a new order
            statusReason: null,
          );

      // If createOrder completes without an error, it was successful.
      if (mounted) {
        showSnackBar(context, 'Order Created Successfully!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle the failure from the controller
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the current user to get their ID for the order
    final currentUser = ref.watch(currentUserDetailsProvider);
    // Watch the controller's loading state to update the UI
    final isLoading = ref.watch(orderControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            size: 30,
          ),
        ),
        title: const Text(
          'Create New Order',
        ),
      ),
      // Use a Consumer to handle the async state of the current user
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
                child: Text('Could not load user data. Please re-login.'));
          }
          return SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                        controller: customerNameController,
                        hintText: 'Customer Full Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a customer name';
                          }
                          return null;
                        }),
                    const SizedBox(height: 15.0),
                    CustomTextField(
                        controller: customerPhoneController,
                        hintText: 'Customer Mobile Number',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        }),
                    const SizedBox(height: 15.0),
                    CustomTextField(
                        controller: customerEmailController,
                        hintText: 'Customer Email (Optional)',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 15.0),
                    CustomTextField(
                        controller: customerAddressController,
                        hintText: 'Customer Address',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        }),
                    const SizedBox(height: 15.0),
                    // Company Dropdown
                    ref.watch(getCompaniesProvider).when(
                          data: (companies) {
                            return DropdownButtonFormField<CompanyModel>(
                              value: _selectedCompany,
                              hint: const Text('Select Company'),
                              onChanged: (company) {
                                setState(() {
                                  _selectedCompany = company;
                                  _selectedProduct =
                                      null; // Reset product when company changes
                                });
                              },
                              items: companies
                                  .map(
                                    (company) => DropdownMenuItem(
                                      value: company,
                                      child: Text(
                                        '${company.companyName} (${company.industryName ?? 'N/A'})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a company';
                                }
                                return null;
                              },
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stackTrace) => Text('Error: $error'),
                        ),
                    const SizedBox(height: 15.0),
                    // Product Dropdown (depends on selected company)
                    if (_selectedCompany != null)
                      ref
                          .watch(getProductsByCompanyProvider(
                              _selectedCompany!.id))
                          .when(
                            data: (products) {
                              return DropdownButtonFormField<ProductModel>(
                                value: _selectedProduct,
                                hint: const Text('Select Product'),
                                onChanged: (product) {
                                  setState(() {
                                    _selectedProduct = product;
                                  });
                                },
                                items: products
                                    .map(
                                      (product) => DropdownMenuItem(
                                        value: product,
                                        child: Text(product.productName),
                                      ),
                                    )
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a product';
                                  }
                                  return null;
                                },
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stackTrace) => Text('Error: $error'),
                          ),
                    const SizedBox(height: 15.0),
                    const Divider(height: 30),
                    const Text('Invoice Details',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15.0),
                    CustomTextField(
                      controller: productPriceController,
                      hintText: 'Product Price',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    CustomTextField(
                      controller: shippingController,
                      hintText: 'Shipping Cost (Optional)',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 15.0),
                    CustomTextField(
                      controller: taxRateController,
                      hintText: 'Tax Rate (e.g., 0.08) (Optional)',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20.0),
                    FlatButton(
                      onTap: isLoading ? () {} : () => onSubmit(user.id),
                      buttonText: isLoading ? 'Submitting...' : 'Submit Order',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}
