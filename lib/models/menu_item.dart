class MenuVariation {
  final String size;
  final double price;

  MenuVariation({required this.size, required this.price});

  factory MenuVariation.fromJson(Map<String, dynamic> json) {
    return MenuVariation(
      size: json['size'] ?? "",
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'price': price,
    };
  }
}

class MenuItem {
  final String name;
  final double price; // Base price or "starting at" price
  final String category;
  final String? description;
  final List<MenuVariation>? variations;

  MenuItem({
    required this.name,
    required this.price,
    required this.category,
    this.description,
    this.variations,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'] ?? "Unknown",
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? "Other",
      description: json['description'],
      variations: json['variations'] != null
          ? (json['variations'] as List)
              .map((v) => MenuVariation.fromJson(v))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'variations': variations?.map((v) => v.toJson()).toList(),
    };
  }
}
