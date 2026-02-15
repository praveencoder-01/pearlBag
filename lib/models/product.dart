class ProductInfoSectionData {
  final String title;
  final String description;
  final String image;

  ProductInfoSectionData({
    required this.title,
    required this.description,
    required this.image,
  });

  factory ProductInfoSectionData.fromMap(Map<String, dynamic> map) {
    return ProductInfoSectionData(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final String category;
  final String description;
  final String shippingPolicy;
  final String returnPolicy;
  final Map<String, String> specs;
  final List<String> images; // 🔥 4 images
  final String imageUrl; // 🔥 first image (list[0])
  final String cartImage;
  int quantity;

  final ProductInfoSectionData infoSection;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.category,
    required this.description,
    required this.shippingPolicy,
    required this.returnPolicy,
    required this.images,
    required this.imageUrl,
    required this.cartImage,
    this.quantity = 1,
    required this.infoSection,
    required this.specs,
  });

  /// 🔥 FIRESTORE → PRODUCT
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    final rawSpecs = map['specs'];
    final specsMap = rawSpecs is Map<String, dynamic>
        ? rawSpecs
        : <String, dynamic>{};

    final specs = specsMap.map(
      (key, value) => MapEntry(key.toString(), (value ?? '').toString()),
    );

    // images
    final List<String> imgs = map['imageUrls'] != null
        ? List<String>.from(map['imageUrls'])
        : [];

    // infoSection safe parse (because sometimes it's "" in Firestore)
    final infoRaw = map['infoSection'];
    final Map<String, dynamic> infoMap = infoRaw is Map<String, dynamic>
        ? infoRaw
        : <String, dynamic>{};

    return Product(
      id: id,
      name: map['name'] ?? '',
      price: ((map['price'] ?? 0) as num).toDouble(),
      originalPrice: map['originalPrice'] != null
          ? (map['originalPrice'] as num).toDouble()
          : ((map['price'] ?? 0) as num).toDouble(),
      category: map['category'] ?? '',
      description: (map['description'] ?? '').toString(),
      shippingPolicy: (map['shippingPolicy'] ?? '').toString(),
      returnPolicy: (map['returnPolicy'] ?? '').toString(),
      images: imgs,
      imageUrl: imgs.isNotEmpty ? imgs.first : '',
      cartImage: imgs.isNotEmpty ? imgs.first : '',
      quantity: map['quantity'] ?? 1,
      infoSection: ProductInfoSectionData.fromMap(infoMap),
      specs: specs,
    );
  }

  Product copyWith({int? quantity}) {
    return Product(
      id: id,
      name: name,
      price: price,
      originalPrice: originalPrice,
      category: category,
      description: description,
      shippingPolicy: shippingPolicy,
      returnPolicy: returnPolicy,
      images: images,
      imageUrl: imageUrl,
      cartImage: cartImage,
      quantity: quantity ?? this.quantity,
      infoSection: infoSection,
      specs: specs,
    );
  }
}
