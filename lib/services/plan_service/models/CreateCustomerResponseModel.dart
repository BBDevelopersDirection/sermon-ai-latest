class RazorpayCustomerResponse {
  final bool success;
  final Customer? customer;
  final String message;

  RazorpayCustomerResponse({
    required this.success,
    required this.customer,
    required this.message,
  });

  factory RazorpayCustomerResponse.fromJson(Map<String, dynamic> json) {
    return RazorpayCustomerResponse(
      success: json['success'] ?? false,
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'customer': customer?.toJson(),
      'message': message,
    };
  }
}

class Customer {
  final String razorpayCustomerId;
  final String userId;
  final String name;
  final String email;
  final String contact;

  Customer({
    required this.razorpayCustomerId,
    required this.userId,
    required this.name,
    required this.email,
    required this.contact,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      razorpayCustomerId: json['razorpayCustomerId'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razorpayCustomerId': razorpayCustomerId,
      'userId': userId,
      'name': name,
      'email': email,
      'contact': contact,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
