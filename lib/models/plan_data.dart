import 'dart:convert';

class PlanItem {
  final int? id;
  final String planDuration;
  final String planType;

  PlanItem({
    this.id,
    required this.planDuration,
    required this.planType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planDuration': planDuration,
      'planType': planType,
    };
  }

  factory PlanItem.fromMap(Map<String, dynamic> map) {
    return PlanItem(
      id: map['id']?.toInt() ?? 0,
      planDuration: map['planDuration'] ?? '',
      planType: map['planType'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PlanItem.fromJson(String source) => PlanItem.fromMap(json.decode(source));

  @override
  String toString() => 'PlanItem(id: $id, planDuration: $planDuration, planType: $planType)';
}
