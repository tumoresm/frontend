import 'package:fieldforce/features/companies/model/company_model.dart';
import 'package:fieldforce/features/order/model/order_model.dart';

/// Calculates the commission for a sales representative based on an order.
///
/// This function defaults the commission to a fixed percentage of the totalInvoice's
/// standard price defined in order, if the company didn't specify the commissionPerOrder
///
/// Parameters:
/// - order: The Order object for which commission is calculated.
/// - company: The Company object associated with the order.
/// - commissionRate: The commission rate as a decimal (e.g., 0.15 for 15%) or as it will defined by each company in their commissionPerOrder.
///
/// Returns:
/// - The calculated commission amount as a double.
/// - Returns null if the order status associated with the order is not "approved".
double? calculateCommission({
  required OrderModel order,
  required CompanyModel company,
  double commissionRate = 0.15,
}) {
  if (order.orderStatus != OrderStatus.approved) {
    return null;
  }

  final double invoiceTotal = order.invoiceTotal;
  // ignore: unnecessary_null_comparison
  // if (invoiceTotal == null) {
  //   return null;
  // }

  // Assumes `CompanyModel` has a nullable `double` property `commissionPerOrder`.
  final double effectiveRate = company.commissionPerOrder;

  return invoiceTotal * effectiveRate;
}

/// Calculates the total balance for a sales representative by summing up all commissions from a list of orders.
///
/// It iterates through each order, calculates the commission, and adds it to a running total.
/// Orders that are not 'approved' or have invalid invoice amounts are skipped.
/// This function assumes that the `CompanyModel` has an `id` and a nullable `commissionPerOrder` property.
///
/// Parameters:
/// - orders: A list of `OrderModel` objects for the representative.
/// - companies: A list of all `CompanyModel` objects to look up company-specific commission rates.
///
/// Returns:
/// - The total calculated balance as a double.
double calculateTotalBalance({
  required List<OrderModel> orders,
  required List<CompanyModel> companies,
}) {
  double totalBalance = 0.0;
  final companyMap = {for (var company in companies) company.id: company};

  for (final order in orders) {
    final company = companyMap[order.companyId];
    if (company != null) {
      final commission = calculateCommission(order: order, company: company);
      totalBalance += commission ?? 0.0;
    }
  }

  return totalBalance;
}
