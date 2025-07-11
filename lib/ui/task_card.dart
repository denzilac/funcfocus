import 'package:flutter/material.dart';
import '../task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({Key? key, required this.task}) : super(key: key);

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'home': return Color(0xFF1976D2);   // Dark Blue
    case 'work': return Color(0xFF6D4C41);   // Dark Brown
    case 'focus': return Color(0xFF8E24AA);  // Dark Purple
    case 'health': return Color(0xFF2E7D32);  // Dark Green
    // New Categories
    case 'game': return Color(0xFFF57C00);   // Dark Orange
    case 'chores': return Color(0xFF00796B);  // Dark Teal
    case 'data': return Color(0xFF3949AB);   // Dark Indigo
    default: return Colors.grey.shade800;
  }
}

  @override
  Widget build(BuildContext context) {
    final bool isTopTask = task.order == 0;
    final deferralColor = task.deferralCount > (task.maxDeferrals / 2)
        ? Colors.red.shade300 : Colors.white.withOpacity(0.8);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTopTask ? 8.0 : 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: isTopTask ? Colors.purple.withOpacity(0.3) : Colors.black.withOpacity(0.5),
            blurRadius: 8, spreadRadius: isTopTask ? 2 : 0, offset: Offset(0, 4))],
        color: _getCategoryColor(task.category),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 90.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 45.0),
                      child: Text(task.title, style: TextStyle(fontSize: 18.0,
                          fontWeight: isTopTask ? FontWeight.bold : FontWeight.normal, color: Colors.white)),
                    ),
                    if (task.description.isNotEmpty) ...[
                      SizedBox(height: 4.0),
                      Text(task.description, style: TextStyle(fontSize: 12.0, color: Colors.white.withOpacity(0.8))),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 14.0),
                child: Row(
                  children: [
                    if (task.deferralCount > 0)
                      Text('${task.deferralCount}', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: deferralColor)),
                    if (task.deferralCount > 0 && task.isRecurring)
                      SizedBox(width: 8.0),
                    if (task.isRecurring)
                      Icon(Icons.repeat, size: 16.0, color: Colors.white.withOpacity(0.8)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}