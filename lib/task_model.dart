import 'package:flutter/material.dart';

class Task {
  String id;
  String title;
  String description;
  String category;
  int order;
  int deferralCount;
  int maxDeferrals;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.order,
    this.deferralCount = 0,
    this.maxDeferrals = 5,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'order': order,
        'deferralCount': deferralCount,
        'maxDeferrals': maxDeferrals,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        category: json['category'],
        order: json['order'],
        deferralCount: json['deferralCount'],
        maxDeferrals: json['maxDeferrals'] ?? 5,
      );
}