class Book {
  final String id, title, author, genre, description;
  final double price;
  final String? coverUrl;
  const Book({
    required this.id, 
    required this.title, 
    required this.author, 
    required this.genre, 
    required this.description, 
    required this.price, 
    this.coverUrl
  });
}
