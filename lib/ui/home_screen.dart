import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../task_service.dart';
import 'task_card.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                tooltip: 'Sign Out & Reset',
                onPressed: () => taskService.signOut(),
              ),
              Tooltip(
                message: "Swipe top item to complete or defer.\nDrag other items to reorder.",
                child: Icon(Icons.info_outline, color: Colors.grey[600]),
              ),
              SizedBox(width: 16),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: taskService.canUndo,
                  child: FloatingActionButton.small(
                    heroTag: 'undo_button',
                    onPressed: () => taskService.undoLastAction(),
                    child: Icon(Icons.undo),
                    backgroundColor: Colors.grey.shade700,
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'add_button',
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AddTaskScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          body: _buildBody(taskService),
        );
      },
    );
  }

// In _HomeScreenState class
Widget _buildBody(TaskService taskService) {
  if (taskService.isLoading) {
    return Center(child: CircularProgressIndicator());
  }
  if (taskService.errorMessage != null) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Error: ${taskService.errorMessage}\nPlease restart the app.",
          textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.red)),
      ),
    );
  }
  if (taskService.tasks.isEmpty) {
    return Center(child: Text("All done! Add new tasks with the (+)",
      style: TextStyle(fontSize: 18, color: Colors.grey)));
  }

  return ReorderableListView.builder(
    onReorder: (oldIndex, newIndex) {
      // First, ensure your TaskService has the safety check:
      // if (oldIndex == 0 || newIndex == 0) return;
      taskService.reorderTask(oldIndex, newIndex);
    },
    itemCount: taskService.tasks.length,
    itemBuilder: (context, index) {
      final task = taskService.tasks[index];
      
      // The top item (index 0) remains a Dismissible, which is correct.
      // It should not be draggable.
      if (index == 0) {
        // This key is crucial for Dismissible.
        return Dismissible(
          key: ValueKey(task.id), 
          // ... your existing Dismissible code is perfect and remains unchanged ...
          background: Container(color: Colors.green, alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 20.0), child: Icon(Icons.check_circle_outline, color: Colors.white)),
          secondaryBackground: Container(color: Colors.orange, alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20.0), child: Icon(Icons.arrow_downward, color: Colors.white)),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              final canDefer = await taskService.deferTask(task.id);
              if (!canDefer && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(task.deferralCount >= task.maxDeferrals ? "Cannot defer anymore!" : "Cannot defer the last task."),
                  backgroundColor: Colors.red,
                ));
              }
              return false;
            } else { return true; }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              taskService.completeTask(task.id);
            }
          },
          // Important: Pass the key to the child as well for widget tree stability.
          child: TaskCard(key: ValueKey('card_${task.id}'), task: task),
        );
      } 
      // --- THIS IS THE FIX ---
      // For all other items, we make them draggable.
      else {
        // This key is crucial for ReorderableListView.
        return ReorderableDelayedDragStartListener(
          key: ValueKey(task.id),
          index: index,
          child: Row(
            children: [
              Expanded(
                child: TaskCard(task: task),
              ),
              // This is the drag handle the user will press and hold.
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.drag_handle, color: Colors.grey),
              ),
            ],
          ),
        );
      }
    },
  );
}
}