import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String selectedCategory = "All";
  String selectedBrand = "All";
  String selectedSort = "None";

  final List<Map<String, dynamic>> products = [
    {
      "id": "1",
      "title": "Yoga Mat",
      "price": "₹499",
      "category": "Yoga",
      "brand": "Boldfit",
      "amazon": "https://www.amazon.in/s?k=boldfit+yoga+mat",
      "image": "https://m.media-amazon.com/images/I/617gCKmEkJL._SX679_.jpg",
      "flipkart": "https://www.flipkart.com/search?q=boldfit+yoga+mat",
    },
    {
      "id": "2",
      "title": "Resistance Band Set",
      "price": "₹629",
      "category": "Strength",
      "brand": "Fashnex",
       "image": "https://m.media-amazon.com/images/I/71-87y93B+L._SX679_.jpg",
      "amazon": "https://www.amazon.in/s?k=fashnex+resistance+band",
      "flipkart": "https://www.flipkart.com/search?q=strauss+resistance+band",
    },
    {
      "id": "3",
      "title": "Dumbbells (Pair)",
      "price": "₹1,349",
      "category": "Strength",
      "brand": "AmazonBasics",
       "image": "https://m.media-amazon.com/images/I/71LGtEZNG4L._SX679_.jpg",
      "amazon": "https://www.amazon.in/s?k=amazonbasics+dumbbells",
      "flipkart": "https://www.flipkart.com/search?q=dumbbells",
    },
    {
      "id": "4",
      "title": "Yoga Blocks (2 pcs)",
      "price": "₹789",
      "category": "Yoga",
      "brand": "Boldfit",
      "image": "https://m.media-amazon.com/images/I/71nw6VX3HhL._SX679_.jpg",
      "amazon": "https://www.amazon.in/s?k=boldfit+yoga+blocks",
      "flipkart": "https://www.flipkart.com/search?q=yoga+blocks",
    },
    {
      "id": "5",
      "title": "Men Gym T-Shirt",
      "price": "₹399",
      "category": "Clothing",
      "brand": "Boldfit",
       "image": "https://m.media-amazon.com/images/I/61oSqmNgHYL._SX679_.jpg",
      "amazon": "https://www.amazon.in/s?k=boldfit+gym+tshirt",
      "flipkart": "https://www.flipkart.com/search?q=boldfit+gym+tshirt",
    },
    {
    "id": "6",
    "title": "Women Yoga Pants",
    "price": "₹549",
    "category": "Clothing",
    "brand": "HRX",
    "image": "https://m.media-amazon.com/images/I/61xkSXB25xL._SX569_.jpg",
    "amazon": "https://www.amazon.in/s?k=yoga+pants+women",
    "flipkart": "https://www.flipkart.com/search?q=yoga+pants+women",
  },

  {
    "id": "7",
    "title": "Skipping Rope",
    "price": "₹199",
    "category": "Accessories",
    "brand": "Boldfit",
    "image": "https://m.media-amazon.com/images/I/61JtE2osFV L._SX522_.jpg",
    "amazon": "https://www.amazon.in/s?k=skipping+rope",
    "flipkart": "https://www.flipkart.com/search?q=skipping+rope",
  },

  {
    "id": "8",
    "title": "Foam Roller",
    "price": "₹699",
    "category": "Yoga",
    "brand": "AmazonBasics",
    "image": "https://m.media-amazon.com/images/I/71S1fSx2DhL._SX522_.jpg",
    "amazon": "https://www.amazon.in/s?k=foam+roller",
    "flipkart": "https://www.flipkart.com/search?q=foam+roller",
  },

  {
    "id": "9",
    "title": "Kettlebell 8kg",
    "price": "₹1,199",
    "category": "Strength",
    "brand": "Boldfit",
    "image": "https://m.media-amazon.com/images/I/61p1+t0bkkL._SX569_.jpg",
    "amazon": "https://www.amazon.in/s?k=kettlebell",
    "flipkart": "https://www.flipkart.com/search?q=kettlebell",
  },

  {
    "id": "10",
    "title": "Push-Up Bars",
    "price": "₹349",
    "category": "Strength",
    "brand": "Fashnex",
    "image": "https://m.media-amazon.com/images/I/71k1JrVN6xL._SX425_.jpg",
    "amazon": "https://www.amazon.in/s?k=push+up+bar",
    "flipkart": "https://www.flipkart.com/search?q=push+up+bar",
  },

  {
    "id": "11",
    "title": "Sports Water Bottle",
    "price": "₹299",
    "category": "Accessories",
    "brand": "Boldfit",
    "image": "https://m.media-amazon.com/images/I/61xQF+xr3QL._SX522_.jpg",
    "amazon": "https://www.amazon.in/s?k=sports+water+bottle",
    "flipkart": "https://www.flipkart.com/search?q=sports+bottle",
  },

  ];

  List<Map<String, dynamic>> filteredProducts = [];

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
      wishlist.contains(id) ? wishlist.remove(id) : wishlist.add(id);
      saveWishlist();
    });
  }

  void applyFilters() {
    String query = searchController.text.toLowerCase();

    List<Map<String, dynamic>> results = products.where((item) {
      bool s = item["title"].toLowerCase().contains(query);
      bool c = selectedCategory == "All" || item["category"] == selectedCategory;
      bool b = selectedBrand == "All" || item["brand"] == selectedBrand;
      return s && c && b;
    }).toList();

    if (selectedSort == "Price: Low to High") {
      results.sort((a, b) => int.parse(a["price"].replaceAll(RegExp(r'[^0-9]'), '')) -
          int.parse(b["price"].replaceAll(RegExp(r'[^0-9]'), '')));
    }

    if (selectedSort == "Price: High to Low") {
      results.sort((a, b) => int.parse(b["price"].replaceAll(RegExp(r'[^0-9]'), '')) -
          int.parse(a["price"].replaceAll(RegExp(r'[^0-9]'), '')));
    }

    setState(() => filteredProducts = results);
  }

  // ---------------- CATEGORY BUTTON ----------------

  Widget categoryButton(String label) {
    bool selected = selectedCategory == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () {
          setState(() => selectedCategory = label);
          applyFilters();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFA998FF) : const Color(0xFFD4CDFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- PRODUCT CARD ----------------

  Widget productCard(Map<String, dynamic> item) {
    bool fav = wishlist.contains(item["id"]);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item["title"]),
        subtitle: Text(item["price"]),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                fav ? Icons.favorite : Icons.favorite_border,
                color: fav ? Colors.red : Colors.grey,
              ),
              onPressed: () => toggleWishlist(item["id"]),
            ),
            const Icon(Icons.arrow_forward_ios),
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
  }

  // ---------------- UI SECTION ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDEBFF),
              Color(0xFFDCD6FF),
              Color(0xFFC9C2FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // TOP SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    // BACK + TITLE + WISHLIST
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "AlignMe Marketplace",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border, size: 28),
                          onPressed: openWishlist,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // SEARCH BAR
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // CATEGORY SCROLL
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          categoryButton("All"),
                          categoryButton("Yoga"),
                          categoryButton("Strength"),
                          categoryButton("Accessories"),
                          categoryButton("Clothing"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // FILTERS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSort,
                        decoration: const InputDecoration(
                          labelText: "Sort",
                          border: InputBorder.none,
                        ),
                        items: ["None", "Price: Low to High", "Price: High to Low"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          selectedSort = v!;
                          applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedBrand,
                        decoration: const InputDecoration(
                          labelText: "Brand",
                          border: InputBorder.none,
                        ),
                        items: ["All", "Boldfit", "Fashnex", "AmazonBasics", "HRX"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          selectedBrand = v!;
                          applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PRODUCT LIST
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, i) {
                    return productCard(filteredProducts[i]);
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void openWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WishlistPage(
          wishlist: wishlist,
          products: products,
          onToggle: toggleWishlist,
        ),
      ),
    );
  }
}


// ---------------- PRODUCT DETAILS PAGE ----------------
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
      body: Container(
        width: double.infinity,

        // FULL-SCREEN GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDEBFF),
              Color(0xFFDCD6FF),
              Color(0xFFC9C2FF),
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // --------- TOP BAR (Back + Title) ----------
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            product["title"],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),


// ---------- PRODUCT IMAGE CLEAN & MODERN ----------
Container(
  margin: const EdgeInsets.only(top: 10, bottom: 20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: Image.network(
      product["image"],
      width: double.infinity,
      height: 260,
      fit: BoxFit.contain,

      // ★ FIX: Show placeholder if image fails ★
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 260,
          width: double.infinity,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported,
            size: 70,
            color: Colors.grey,
          ),
        );
      },
    ),
  ),
),


                    // --------- PRODUCT INFO ----------
                    Text(
                      "Price: ${product["price"]}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Category: ${product["category"]}",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Brand: ${product["brand"]}",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 30),

                    // --------- AMAZON BUTTON ----------
                    Center(
                      child: ElevatedButton(
                        onPressed: () => openLink(context, product["amazon"]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Buy on Amazon",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --------- FLIPKART BUTTON ----------
                    Center(
                      child: ElevatedButton(
                        onPressed: () => openLink(context, product["flipkart"]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Buy on Flipkart",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40), // keeps gradient visible at bottom
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}






// ---------------- WISHLIST PAGE ----------------

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
    final favProducts =
        products.where((p) => wishlist.contains(p["id"])).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("My Wishlist")),
      body: favProducts.isEmpty
          ? const Center(child: Text("No favorites yet ❤️"))
          : ListView.builder(
              itemCount: favProducts.length,
              itemBuilder: (context, i) {
                final item = favProducts[i];
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
