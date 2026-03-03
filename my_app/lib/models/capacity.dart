class Capacity {
  final int currentCount;
  final int maxCapacity;
  final int peakCapacity;
  final bool isPeak;
  final int percentage;

  Capacity({
    required this.currentCount,
    required this.maxCapacity,
    required this.peakCapacity,
    required this.isPeak,
    required this.percentage,
  });

  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(
      currentCount: json['current_count'] ?? 0,
      maxCapacity: json['max_capacity'] ?? 100,
      peakCapacity: json['peak_capacity'] ?? 80,
      isPeak: json['is_peak'] ?? false,
      percentage: json['percentage'] ?? 0,
    );
  }
}
