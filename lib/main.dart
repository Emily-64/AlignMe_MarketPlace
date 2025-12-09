import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlignMe Marketplace',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MarketplaceHome(),
    );
  }
}

class MarketplaceHome extends StatefulWidget {
  const MarketplaceHome({super.key});

  @override
  State<MarketplaceHome> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHome> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> products = [
    {
      "title": "Yoga Mat",
      "price": "₹799",
      "category": "Yoga",
      "brand": "FitPro",
      "amazon": "https://www.amazon.in/s?k=yoga+mat",
      "flipkart": "https://www.flipkart.com/search?q=yoga+mat",
    },
    {
      "title": "Resistance Band",
      "price": "₹499",
      "category": "Strength",
      "brand": "FlexMax",
      "amazon": "https://www.amazon.in/s?k=resistance+band",
      "flipkart": "https://www.flipkart.com/search?q=resistance+band",
    },
    {
      "title": "Dumbbells (Pair)",
      "price": "₹1499",
      "category": "Strength",
      "brand": "ProLift",
      "amazon": "https://www.amazon.in/s?k=dumbbells",
      "flipkart": "https://www.flipkart.com/search?q=dumbbells",
    },
    {
      "title": "Yoga Blocks",
      "price": "₹399",
      "category": "Yoga",
      "brand": "ZenFit",
      "amazon": "https://www.amazon.in/s?k=yoga+blocks",
      "flipkart": "https://www.flipkart.com/search?q=yoga+blocks",
    },
  ];

  List<Map<String, dynamic>> filteredProducts = [];

  String selectedCategory = "All";
  String selectedBrand = "All";
  String selectedSort = "None";

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(products);

    searchController.addListener(() {
      applyFilters();
    });
  }

  void applyFilters() {
    String query = searchController.text.toLowerCase();

    List<Map<String, dynamic>> results = products.where((item) {
      bool matchesSearch = item["title"].toLowerCase().contains(query);
      bool matchesCategory =
          selectedCategory == "All" || item["category"] == selectedCategory;
      bool matchesBrand = selectedBrand == "All" || item["brand"] == selectedBrand;
      return matchesSearch && matchesCategory && matchesBrand;
    }).toList();

    if (selectedSort == "Price: Low to High") {
      results.sort((a, b) =>
          int.parse(a["price"].replaceAll(RegExp(r'[^0-9]'), '')) -
          int.parse(b["price"].replaceAll(RegExp(r'[^0-9]'), '')));
    } else if (selectedSort == "Price: High to Low") {
      results.sort((a, b) =>
          int.parse(b["price"].replaceAll(RegExp(r'[^0-9]'), '')) -
          int.parse(a["price"].replaceAll(RegExp(r'[^0-9]'), '')));
    }

    setState(() {
      filteredProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AlignMe Marketplace"),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search accessories...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Categories
            const Text(
              "Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                categoryChip("Yoga"),
                categoryChip("Strength"),
                categoryChip("Accessories"),
                categoryChip("All"),
              ],
            ),
            const SizedBox(height: 20),

            // Filters
            Row(
              children: [
                filterDropdown(
                  "Sort",
                  ["None", "Price: Low to High", "Price: High to Low"],
                  selectedSort,
                  (value) {
                    selectedSort = value!;
                    applyFilters();
                  },
                ),
                const SizedBox(width: 10),
                filterDropdown(
                  "Brand",
                  ["All", "FitPro", "FlexMax", "ProLift", "ZenFit"],
                  selectedBrand,
                  (value) {
                    selectedBrand = value!;
                    applyFilters();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Product List
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final item = filteredProducts[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(item["title"]),
                      subtitle: Text(item["price"]),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetails(product: item),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetails(product: item),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryChip(String label) {
    bool isSelected = selectedCategory == label;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          selectedCategory = label;
        });
        applyFilters();
      },
    );
  }

  Widget filterDropdown(
      String label, List<String> options, String selectedValue, Function(String?) onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: options
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class ProductDetails extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetails({super.key, required this.product});

  Future<void> openLink(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product["title"])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Price: ${product["price"]}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Category: ${product["category"]}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Brand: ${product["brand"]}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => openLink(context, product["amazon"]),
              child: const Text("Buy on Amazon"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => openLink(context, product["flipkart"]),
              child: const Text("Buy on Flipkart"),
            ),
          ],
        ),
      ),
    );
  }
}
