import 'package:flutter/material.dart';
import '../task_model.dart';
import '../utils/app_colors.dart'; // <-- IMPORT our new color file

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({Key? key, required this.task}) : super(key: key);

  // The local _getCategoryColor function is now GONE!

  @override
  Widget build(BuildContext context) {
    final bool isTopTask = task.order == 0;
    // Use a slightly darker red for the deferral count to make it stand out
    final deferralColor = task.deferralCount > (task.maxDeferrals / 2)
        ? Colors.red.shade400 : Colors.white.withOpacity(0.8);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTopTask ? 8.0 : 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: isTopTask ? Colors.purple.withOpacity(0.2) : Colors.black.withOpacity(0.3),
            blurRadius: 8, spreadRadius: isTopTask ? 2 : 0, offset: Offset(0, 4))],
        // We now get the color from our central AppColors class
        color: AppColors.get(task.category),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: /* ... rest of your code is unchanged ... */
      ClipRRect(
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