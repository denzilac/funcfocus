import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../task_service.dart';
import '../utils/app_colors.dart'; // <-- IMPORT our new color file

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
  
  String? _category;
  
  final List<String> _categoryList = ['Home', 'Work', 'Project', 'Health', 'Gardening', 'Entertain', 'Chores'];

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
        category: _category!,
        maxDeferrals: int.tryParse(_maxDeferralsController.text) ?? 5,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.get(_category);

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
                hint: Text('Select a category...'),
                decoration: InputDecoration(labelText: 'Category', focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: activeColor, width: 2.0))),
                items: _categoryList.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) => (value == null) ? 'Please select a category' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _maxDeferralsController,
                decoration: InputDecoration(labelText: 'Max Deferrals', focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: activeColor, width: 2.0))),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a number' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}