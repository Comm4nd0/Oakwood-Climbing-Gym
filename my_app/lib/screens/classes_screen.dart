import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/gym_class.dart';
import '../widgets/class_card.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<GymClass> _classes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final classes = await apiService.getClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load classes. Pull to refresh.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      body: RefreshIndicator(
        onRefresh: _loadClasses,
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
              onPressed: _loadClasses,
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
        return ClassCard(gymClass: _classes[index]);
      },
    );
  }
}
