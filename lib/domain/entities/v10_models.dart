class ProductMetricPoint {
  const ProductMetricPoint({
    required this.productId,
    required this.simulationMinutes,
    required this.users,
    required this.dau,
    required this.mau,
    required this.revenue,
    required this.requiredCompute,
    required this.rating,
    required this.retention30d,
    required this.churnRate,
  });

  final String productId;
  final int simulationMinutes;
  final int users;
  final int dau;
  final int mau;
  final double revenue;
  final double requiredCompute;
  final double rating;
  final double retention30d;
  final double churnRate;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'simulationMinutes': simulationMinutes,
    'users': users,
    'dau': dau,
    'mau': mau,
    'revenue': revenue,
    'requiredCompute': requiredCompute,
    'rating': rating,
    'retention30d': retention30d,
    'churnRate': churnRate,
  };

  factory ProductMetricPoint.fromJson(Map<String, Object?> json) =>
      ProductMetricPoint(
        productId: json['productId']! as String,
        simulationMinutes: (json['simulationMinutes']! as num).toInt(),
        users: (json['users']! as num).toInt(),
        dau: (json['dau']! as num).toInt(),
        mau: (json['mau']! as num).toInt(),
        revenue: (json['revenue']! as num).toDouble(),
        requiredCompute: (json['requiredCompute']! as num).toDouble(),
        rating: (json['rating']! as num).toDouble(),
        retention30d: (json['retention30d']! as num).toDouble(),
        churnRate: (json['churnRate']! as num).toDouble(),
      );
}
