import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/climbing_route.dart';
import '../widgets/route_card.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  List<ClimbingRoute> _routes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final routes = await apiService.getRoutes();
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load routes. Pull to refresh.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: filter dialog
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRoutes,
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
              onPressed: _loadRoutes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_routes.isEmpty) {
      return const Center(
        child: Text('No routes available right now.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _routes.length,
      itemBuilder: (context, index) {
        return RouteCard(route: _routes[index]);
      },
    );
  }
}
