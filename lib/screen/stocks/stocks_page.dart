import 'package:dahab_app/screen/stocks/stocks_details_page.dart';
import 'package:flutter/material.dart';
import 'package:dahab_app/services/auth_service.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  List<Map<String, dynamic>> ownedStocks = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchOwnedStocks();
  }

  Future<void> fetchOwnedStocks() async {
    try {
      final data = await AuthService().getUserInvestments();
      setState(() {
        ownedStocks = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load investments.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child:
                      Text(error!, style: const TextStyle(color: Colors.red)))
              : ownedStocks.isEmpty
                  ? const Center(child: Text("You don't own any stocks yet."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: ownedStocks.length,
                      itemBuilder: (context, index) {
                        final stock = ownedStocks[index];

                        final totalValue = stock['amountInvested'] ?? 0.0;
                        final numberOfShares = stock['numberOfShares'] ?? 0;
                        final sharePrice = numberOfShares > 0
                            ? totalValue / numberOfShares
                            : 0.0;

                        final dailyProfit =
                            (stock['expectedMonthlyReturn'] ?? 0) / 30;
                        final annualProfit = stock['expectedAnnualReturn'] ?? 0;

                        final isRising = dailyProfit >= 0;
                        final isProfitable = annualProfit >= 0;

                        return InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StockDetailsPage(stock: {
                                  ...stock,
                                  'propertyTitle': stock['propertyTitle'],
                                  'sharesOwned': numberOfShares,
                                  'sharePrice': sharePrice,
                                  'dailyProfit': dailyProfit,
                                  'annualProfit': annualProfit,
                                  'isRising': isRising,
                                  'isProfitable': isProfitable,
                                  'availableShares': 999,
                                }),
                              ),
                            );

                            if (result == true) {
                              fetchOwnedStocks();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.blueAccent, width: 2),
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stock['propertyTitle'] ?? '',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildInfoTile(context, 'Shares Owned',
                                        '$numberOfShares'),
                                    _buildInfoTile(context, 'Share Price',
                                        '${sharePrice.toStringAsFixed(2)}\$'),
                                    _buildInfoTile(context, 'Total Value',
                                        '${totalValue.toStringAsFixed(2)}\$'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildProfitTile(
                                        'Daily Profit', dailyProfit),
                                    _buildProfitTile(
                                        'Annual Profit', annualProfit),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildStatusIcon(
                                        isRising,
                                        isRising
                                            ? 'Price Rising'
                                            : 'Price Falling',
                                        rising: true),
                                    const SizedBox(width: 16),
                                    _buildStatusIcon(isProfitable,
                                        isProfitable ? 'Profitable' : 'Losing',
                                        rising: false),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                // ignore: deprecated_member_use
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.6),
                fontSize: 12,
              )),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitTile(String label, double value) {
    final isPositive = value >= 0;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            '${isPositive ? '+' : ''}${value.toStringAsFixed(2)}\$',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool state, String label, {required bool rising}) {
    return Row(
      children: [
        Icon(
          rising
              ? (state ? Icons.trending_up : Icons.trending_down)
              : (state ? Icons.check_circle : Icons.error),
          color: state ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: state ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
