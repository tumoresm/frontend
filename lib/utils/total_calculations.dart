/// Calculates the total invoice amount based on various components.
///
/// This function sums up the base price and additional costs, then applies a tax rate
/// to the subtotal to get the final amount.
///
/// Parameters:
/// - productPrice: The base price of the product.
/// - addons: The total cost of any add-ons.
/// - accessories: The total cost of any accessories.
/// - shipping: The shipping cost.
/// - taxRate: The tax rate to be applied to the subtotal (e.g., 0.08 for 8% tax).
///
/// Returns:
/// - The final calculated invoice total as a double.
double calculateInvoiceTotal({
  required double productPrice,
  double addons = 0.0,
  double accessories = 0.0,
  double shipping = 0.0,
  double taxRate = 0.0,
}) {
  final subtotal = productPrice + addons + accessories + shipping;
  final taxAmount = subtotal * taxRate;
  return subtotal + taxAmount;
}
