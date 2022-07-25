class Order {
    Order({
        required this.id,
        required this.bookId,
        required this.customerName,
        required this.createdBy,
        required this.quantity,
        required this.timestamp,
    });

    final String id;
    final int bookId;
    final String customerName;
    final String createdBy;
    final int quantity;
    final int timestamp;

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        bookId: json["bookId"],
        customerName: json["customerName"],
        createdBy: json["createdBy"],
        quantity: json["quantity"],
        timestamp: json["timestamp"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "bookId": bookId,
        "customerName": customerName,
        "createdBy": createdBy,
        "quantity": quantity,
        "timestamp": timestamp,
    };
}
