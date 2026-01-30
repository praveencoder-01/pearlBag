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
  final String category;
  final String description;

  final List<String> images; // 🔥 4 images
  final String imageUrl; // 🔥 first image (list[0])
  final String cartImage;

  final ProductInfoSectionData infoSection;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.images,
    required this.imageUrl,
    required this.cartImage,
    required this.infoSection,
  });

  /// 🔥 FIRESTORE → PRODUCT
  factory Product.fromMap(String id, Map<String, dynamic> map) {
  final List<String> imgs = map['imageUrls'] != null
      ? List<String>.from(map['imageUrls'])
      : [];

  return Product(
    id: id,
    name: map['name'] ?? '',
    price: (map['price'] as num).toDouble(),
    category: map['category'] ?? '',
    description: map['description'] ?? '',
    images: imgs,
    imageUrl: imgs.isNotEmpty ? imgs.first : '', // ✅ always String
    cartImage: imgs.isNotEmpty ? imgs.first : '', // ✅ always String
    infoSection: ProductInfoSectionData.fromMap(
      map['infoSection'] ?? {},
    ),
  );
}
}