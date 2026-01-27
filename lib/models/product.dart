class ProductInfoSectionData {
  final String title;
  final String description;
  final String image;

  ProductInfoSectionData({
    required this.title,
    required this.description,
    required this.image,
  });
}


class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String cartImage;
  final String category;
  final String description;
  final List<String> images; 


  final ProductInfoSectionData infoSection;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.cartImage,
    required this.category,
    required this.description,
    required this.images,
    required this.infoSection,
  });
}
