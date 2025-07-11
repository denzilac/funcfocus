import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'google_auth_client.dart';
import 'task_model.dart';
import 'notification_service.dart';

const _fileName = 'functional_focus_data.json';

class TaskService extends ChangeNotifier {
  final NotificationService notificationService;

  List<Task> _tasks = [];
  List<Task>? _lastTasksState;
  bool isLoading = true;
  String? errorMessage;
  final _uuid = Uuid();
  drive.DriveApi? _driveApi;
  String? _fileId;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  List<Task> get tasks => _tasks;
  bool get canUndo => _lastTasksState != null;

  TaskService({required this.notificationService}) {
    _initAndLoadFromDrive();
  }

  Future<Map<String, String>?> _getAuthHeaders() async {
    final googleUser = await _googleSignIn.signInSilently();
    if (googleUser == null) return null;
    
    final auth = await googleUser.authentication;
    final accessToken = auth.accessToken;

    if (accessToken == null) return null;
    return {'Authorization': 'Bearer $accessToken'};
  }

  Future<void> _initAndLoadFromDrive() async {
    try {
      Map<String, String>? authHeaders = await _getAuthHeaders();
      if (authHeaders == null) {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          errorMessage = "Sign-in is required.";
          isLoading = false; notifyListeners(); return;
        }
        final auth = await googleUser.authentication;
        final accessToken = auth.accessToken;
        if (accessToken != null) {
          authHeaders = {'Authorization': 'Bearer $accessToken'};
        }
      }

      if (authHeaders == null) {
        errorMessage = "Failed to get authentication headers.";
        isLoading = false; notifyListeners(); return;
      }

      final authClient = GoogleAuthClient(authHeaders);
      _driveApi = drive.DriveApi(authClient);
      await _loadTasksFromCloud();
      _notifyAndRefresh();
    } catch (e) {
      print("Error during sign-in or loading: $e");
      errorMessage = "Failed to load data from Google Drive.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTasksToCloud() async {
    final authHeaders = await _getAuthHeaders();
    if (authHeaders == null) {
      errorMessage = "Authentication expired. Please restart.";
      notifyListeners(); return;
    }
    _driveApi = drive.DriveApi(GoogleAuthClient(authHeaders));
    final jsonString = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    final media = drive.Media(Stream.value(utf8.encode(jsonString)), jsonString.length);
    try {
      if (_fileId == null) {
        final file = drive.File()..name = _fileName..parents = ['appDataFolder'];
        final response = await _driveApi!.files.create(file, uploadMedia: media);
        _fileId = response.id;
      } else {
        await _driveApi!.files.update(drive.File(), _fileId!, uploadMedia: media);
      }
    } catch (e) {
      print("Error saving to cloud: $e");
      errorMessage = "Failed to save data.";
      notifyListeners();
    }
  }
  
  Future<void> _loadTasksFromCloud() async {
    if (_driveApi == null) return;
    try {
      final fileList = await _driveApi!.files.list(spaces: 'appDataFolder', $fields: 'files(id, name)');
      final files = fileList.files;
      if (files == null || files.isEmpty || !files.any((file) => file.name == _fileName)) {
        await _saveTasksToCloud(); return;
      }
      _fileId = files.firstWhere((file) => file.name == _fileName).id;
      final response = await _driveApi!.files.get(_fileId!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final jsonString = await utf8.decodeStream(response.stream);
      if (jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _tasks = jsonList.map((json) => Task.fromJson(json)).toList();
        _sortAndRenumberTasks();
      }
    } catch (e) {
      print("Error loading from cloud: $e");
      errorMessage = "Could not parse data from Drive."; _tasks = [];
    }
  }

  void _backupState() {
    _lastTasksState = _tasks.map((task) => Task.fromJson(task.toJson())).toList();
  }

  void _sortAndRenumberTasks() {
    _tasks.sort((a, b) => a.order.compareTo(b.order));
    for (int i = 0; i < _tasks.length; i++) {
      _tasks[i].order = i;
    }
  }

  Future<void> addTask({ required String title, required String description, required String category, required bool isRecurring, required int maxDeferrals, }) async {
    _backupState();
    _tasks.add(Task(id: _uuid.v4(), title: title, description: description, category: category, order: _tasks.length, isRecurring: isRecurring, maxDeferrals: maxDeferrals));
    await _saveTasksToCloud();
    _notifyAndRefresh();
  }

  Future<void> completeTask(String taskId) async {
    _backupState();
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;
    final task = _tasks[taskIndex];
    if (task.isRecurring) {
      task.order = _tasks.length;
      task.deferralCount = 0;
    } else {
      _tasks.removeAt(taskIndex);
    }
    _sortAndRenumberTasks();
    await _saveTasksToCloud();
    _notifyAndRefresh();
  }

  Future<bool> deferTask(String taskId) async {
    _backupState();
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1 || taskIndex + 1 >= _tasks.length) return false;
    final task = _tasks[taskIndex];
    if (task.deferralCount >= task.maxDeferrals) return false;
    task.deferralCount++;
    final nextTask = _tasks[taskIndex + 1];
    final currentOrder = task.order;
    task.order = nextTask.order;
    nextTask.order = currentOrder;
    _sortAndRenumberTasks();
    await _saveTasksToCloud();
    _notifyAndRefresh();
    return true;
  }

// In TaskService.dart

Future<void> reorderTask(int oldIndex, int newIndex) async {
  _backupState();

  // --- ADD THIS CHECK BACK IN ---
  // This is the business rule: the top item (index 0) cannot be reordered.
  // It protects the "Active Focus Task".
  if (oldIndex == 0 || newIndex == 0) {
    return; // Silently reject the change.
  }
  
  // This logic is correct and now only applies to items below the top one.
  if (newIndex > oldIndex) {
    newIndex -= 1;
  }

  final Task item = _tasks.removeAt(oldIndex);
  _tasks.insert(newIndex, item);

  for (int i = 0; i < _tasks.length; i++) {
    _tasks[i].order = i;
  }

  await _saveTasksToCloud();
  _notifyAndRefresh();
}

  Future<void> undoLastAction() async {
    if (!canUndo) return;
    _tasks = _lastTasksState!;
    _lastTasksState = null;
    await _saveTasksToCloud();
    _notifyAndRefresh();
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _tasks = []; _fileId = null; _driveApi = null; _lastTasksState = null;
    await _initAndLoadFromDrive();
  }

  void updatePersistentNotification() {
    if (kIsWeb) return;
    if (_tasks.isNotEmpty) {
      final topTask = _tasks.first;
      if (!topTask.isRecurring) {
        notificationService.showPersistentNotification(topTask.title, topTask.description, topTask.category);
      } else {
        notificationService.cancelNotification();
      }
    } else {
      notificationService.cancelNotification();
    }
  }

  void _notifyAndRefresh() {
    updatePersistentNotification();
    notifyListeners();
  }
}