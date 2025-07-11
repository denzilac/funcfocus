import 'package:flutter/material.dart';

enum RecurrenceType { daily, weekly, biweekly, monthly }

class RecurrenceRule {
  final RecurrenceType type;
  RecurrenceRule({required this.type});
  Map<String, dynamic> toJson() => {'type': type.toString()};
  static RecurrenceRule fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
        type: RecurrenceType.values
            .firstWhere((e) => e.toString() == json['type']));
  }
}

class Task {
  String id;
  String title;
  String description;
  String category;
  int order;
  int deferralCount;
  bool isRecurring;
  RecurrenceRule? recurrenceRule;
  int maxDeferrals;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.order,
    this.deferralCount = 0,
    this.isRecurring = false,
    this.recurrenceRule,
    this.maxDeferrals = 5,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'order': order,
        'deferralCount': deferralCount,
        'isRecurring': isRecurring,
        'recurrenceRule': recurrenceRule?.toJson(),
        'maxDeferrals': maxDeferrals,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        category: json['category'],
        order: json['order'],
        deferralCount: json['deferralCount'],
        isRecurring: json['isRecurring'],
        recurrenceRule: json['recurrenceRule'] != null
            ? RecurrenceRule.fromJson(json['recurrenceRule'])
            : null,
        maxDeferrals: json['maxDeferrals'] ?? 5,
      );
}