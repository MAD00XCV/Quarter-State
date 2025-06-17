import 'dart:async';
import 'package:dahab_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dahab_app/models/Property';

class PropertyDetailsPage extends StatefulWidget {
  final Property property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  int currentIndex = 0;
  int selectedShares = 0;

  late final PageController _pageController;
  Timer? _autoScrollTimer;

  late final List<String> images;

  @override
  void initState() {
    super.initState();

    // Load images from backend (if empty, fallback to one imageUrl)
    images = widget.property.imageUrls.isNotEmpty
        ? widget.property.imageUrls
        : [widget.property.imageUrl];

    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      int nextPage = (currentIndex + 1) % images.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentIndex = nextPage;
      });
    });
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      currentIndex = index;
    });
  }

  void _increaseShares() {
    if (selectedShares < widget.property.availableShares) {
      setState(() {
        selectedShares++;
      });
    }
  }

  void _decreaseShares() {
    if (selectedShares > 0) {
      setState(() {
        selectedShares--;
      });
    }
  }
void _buyShares() async {
  if (selectedShares > 0 && selectedShares <= widget.property.availableShares) {
    final success = await AuthService().purchaseInvestment(
      widget.property.id,
      selectedShares,
    );

    if (success) {
      setState(() {
        widget.property.collectedShares += selectedShares;
        selectedShares = 0;
      });

      Navigator.pop(context, true);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shares purchased successfully!'),
          backgroundColor: Color(0xFF2196F3),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to purchase shares.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}



  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableShares = widget.property.availableShares;
    final sharePrice = widget.property.sharePrice;
    final totalPrice = selectedShares * sharePrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property.title),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, _) =>
                          const Icon(Icons.broken_image, size: 180),
                    );
                  },
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index % images.length;
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return GestureDetector(
                      onTap: () => _goToPage(index),
                      child: Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentIndex == index ? Colors.blue : Colors.white,
                          border: Border.all(color: Colors.blue),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(widget.property.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Status: ${widget.property.status}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('\$${widget.property.totalValue.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, color: Colors.green)),
                const SizedBox(height: 16),
                const Text("Description not provided", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Shares: ${widget.property.totalShares}", style: const TextStyle(fontSize: 16)),
                    Text("Available: $availableShares", style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                Text("Share Price: \$${sharePrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Select Shares:", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    IconButton(onPressed: _decreaseShares, icon: const Icon(Icons.remove_circle_outline)),
                    Text('$selectedShares', style: const TextStyle(fontSize: 18)),
                    IconButton(onPressed: _increaseShares, icon: const Icon(Icons.add_circle_outline)),
                  ],
                ),
                const SizedBox(height: 16),
                Text("Total Price: \$${totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: selectedShares > 0 ? _buyShares : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Buy Shares"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
