import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

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
  scaffoldBackgroundColor: const Color(0xFFE8ECFF), // Light blue-purple bg
  primaryColor: const Color(0xFF6A1B9A), // Deep purple
  iconTheme: const IconThemeData(color: Color(0xFF4A148C)), // Dark purple icons
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF6A1B9A), // Purple AppBar
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardColor: Colors.white,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple).copyWith(
    secondary: const Color(0xFF4527A0), // Darker purple accent
  ),
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
  List<String> wishlist = [];
final List<Map<String, dynamic>> products = [
  {
    "id": "1",
    "title": "Yoga Mat",
    "price": "₹499",
    "category": "Yoga",
    "brand": "Boldfit",
    "amazon": "https://www.amazon.in/s?k=boldfit+yoga+mat",
    "flipkart": "https://www.flipkart.com/search?q=boldfit+yoga+mat",
  },
  {
    "id": "2",
    "title": "Resistance Band Set",
    "price": "₹629",
    "category": "Strength",
    "brand": "Fashnex",
    "amazon": "https://www.amazon.in/s?k=fashnex+resistance+band",
    "flipkart": "https://www.flipkart.com/search?q=strauss+resistance+band",
  },
  {
    "id": "3",
    "title": "Dumbbells (Pair)",
    "price": "₹1,349",
    "category": "Strength",
    "brand": "AmazonBasics",
    "amazon": "https://www.amazon.in/s?k=amazonbasics+dumbbells",
    "flipkart": "https://www.flipkart.com/search?q=dumbbells",
  },
  {
    "id": "4",
    "title": "Yoga Blocks (2 pcs)",
    "price": "₹789",
    "category": "Yoga",
    "brand": "Boldfit",
    "amazon": "https://www.amazon.in/s?k=boldfit+yoga+blocks",
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
    searchController.addListener(() => applyFilters());

    loadWishlist();
  }

  Future<void> loadWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    wishlist = prefs.getStringList("wishlist") ?? [];
    setState(() {});
  }

  Future<void> saveWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("wishlist", wishlist);
  }

  void toggleWishlist(String id) {
    setState(() {
      if (wishlist.contains(id)) {
        wishlist.remove(id);
      } else {
        wishlist.add(id);
      }
      saveWishlist();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WishlistPage(products: products, wishlist: wishlist, onToggle: toggleWishlist),
                ),
              );
            },
          )
        ],
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

            // Filter
                  
Row(
  children: [
    Expanded(
      child: filterDropdown(
        "Sort",
        ["None", "Price: Low to High", "Price: High to Low"],
        selectedSort,
        (value) {
          selectedSort = value!;
          applyFilters();
        },
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: filterDropdown(
        "Brand",
        ["All", "Boldfit", "Fashnex", "AmazonBasics"],
        selectedBrand,
        (value) {
          selectedBrand = value!;
          applyFilters();
        },
      ),
    ),
  ],
),

            const SizedBox(height: 20),
            const Text(
              "Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final item = filteredProducts[index];
                  bool isFav = wishlist.contains(item["id"]);

                  return Card(
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(item["title"]),
                      subtitle: Text(item["price"]),
                      trailing: Wrap(
                        spacing: 10,
                        children: [
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => toggleWishlist(item["id"]),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 18),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetails(product: item),
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

class WishlistPage extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final List<String> wishlist;
  final Function(String) onToggle;

  const WishlistPage({
    super.key,
    required this.products,
    required this.wishlist,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> favProducts =
        products.where((p) => wishlist.contains(p["id"])).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("My Wishlist")),
      body: favProducts.isEmpty
          ? const Center(child: Text("No favorites yet ❤️"))
          : ListView.builder(
              itemCount: favProducts.length,
              itemBuilder: (context, index) {
                final item = favProducts[index];
                return Card(
                  child: ListTile(
                    title: Text(item["title"]),
                    subtitle: Text(item["price"]),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => onToggle(item["id"]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
