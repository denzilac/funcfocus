import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxDeferralsController = TextEditingController(text: '5');
  bool _isRecurring = false;
  String _category = 'Home';

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'home': return Colors.blue.shade300;
    case 'work': return Colors.brown.shade300;
    case 'focus': return Colors.purple.shade300;
    case 'health': return Colors.green.shade300;
    // New Categories
    case 'game': return Colors.orange.shade300;
    case 'chores': return Colors.teal.shade300;
    case 'data': return Colors.indigo.shade300;
    default: return Colors.grey.shade300;
  }
}

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxDeferralsController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      Provider.of<TaskService>(context, listen: false).addTask(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        isRecurring: _isRecurring,
        maxDeferrals: int.tryParse(_maxDeferralsController.text) ?? 5,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = _getCategoryColor(_category);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: activeColor.withOpacity(0.2),
        elevation: 0,
        title: Text('Add New Task'),
        actions: [IconButton(icon: Icon(Icons.check), onPressed: _saveTask)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title', focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: activeColor, width: 2.0))),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description (Optional)', focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: activeColor, width: 2.0))),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(labelText: 'Category', focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: activeColor, width: 2.0))),
                items: ['Home', 'Work', 'Focus', 'Health', 'Game', 'Chores', 'Data'].map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _maxDeferralsController,
                decoration: InputDecoration(labelText: 'Max Deferrals', focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: activeColor, width: 2.0))),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a number' : null,
              ),
              SizedBox(height: 10),
              SwitchListTile(
                title: Text('Recurring Task'),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
                activeColor: activeColor,
                activeTrackColor: activeColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}