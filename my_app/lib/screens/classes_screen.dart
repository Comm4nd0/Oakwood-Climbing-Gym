import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/gym_class.dart';
import '../widgets/class_card.dart';
import 'add_class_screen.dart';
import 'class_detail_screen.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<GymClass> _classes = [];
  bool _isLoading = true;
  String? _error;
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final results = await Future.wait([
        apiService.getClasses(),
        apiService.getProfile().catchError((_) => <String, dynamic>{}),
      ]);
      final classes = results[0] as List<GymClass>;
      final profile = results[1] as Map<String, dynamic>;

      setState(() {
        _classes = classes;
        _isStaff = profile['is_staff_role'] == true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load classes. Pull to refresh.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddClass() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddClassScreen()),
    );
    if (created == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      floatingActionButton: _isStaff
          ? FloatingActionButton(
              onPressed: _openAddClass,
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_classes.isEmpty) {
      return const Center(
        child: Text('No classes available right now.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final gymClass = _classes[index];
        return ClassCard(
          gymClass: gymClass,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClassDetailScreen(gymClass: gymClass),
              ),
            );
          },
        );
      },
    );
  }
}
