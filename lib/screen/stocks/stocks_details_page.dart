import 'package:dahab_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class StockDetailsPage extends StatelessWidget {
  final Map<String, dynamic> stock;

  const StockDetailsPage({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(stock['propertyTitle']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetailRow("Shares Owned", stock['sharesOwned'].toString()),
                buildDetailRow("Share Price", "\$${stock['sharePrice']}"),
                buildDetailRow(
                    "Available Shares", stock['availableShares'].toString()),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[300]),
                buildDetailRow("Daily Profit", "\$${stock['dailyProfit']}"),
                buildDetailRow("Annual Profit", "\$${stock['annualProfit']}"),
                const Spacer(),
                if (stock['availableShares'] > 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("Buy More Shares"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _showPurchaseDialog(context, stock);
                      },
                    ),
                  )
                else
                  Text(
                    "No more shares available.",
                    style: TextStyle(
                        color: Colors.red[400], fontWeight: FontWeight.bold),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, Map<String, dynamic> stock) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buy Shares"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: "Enter number of shares"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Buy"),
            onPressed: () async {
              final count = int.tryParse(controller.text);
              if (count == null ||
                  count <= 0 ||
                  count > stock['availableShares']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a valid number of shares."),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context); // Close the dialog

              final success = await AuthService().purchaseInvestment(
                stock['id'] ?? stock['propertyId'] ?? 0,
                count,
              );

              if (success) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context, true);
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to purchase shares."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
