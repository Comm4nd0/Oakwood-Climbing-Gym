import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/route_log.dart';

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  List<RouteLog> _logs = [];
  RouteStats? _stats;
  bool _isLoading = true;
  String? _error;

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
        apiService.getRouteLogs(),
        apiService.getRouteStats(),
      ]);
      setState(() {
        _logs = results[0] as List<RouteLog>;
        _stats = results[1] as RouteStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load logbook. Pull to refresh.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logbook')),
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

    return CustomScrollView(
      slivers: [
        if (_stats != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStatChip('Total', _stats!.totalLogs, Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatChip('Sends', _stats!.totalSends, Colors.green),
                  const SizedBox(width: 8),
                  _buildStatChip('Flashes', _stats!.totalFlashes, Colors.amber),
                ],
              ),
            ),
          ),
        if (_logs.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text('No climbs logged yet. Start climbing!'),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final log = _logs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: _attemptIcon(log.attemptType),
                    title: Text(log.routeName),
                    subtitle: Text('${log.routeGrade} - ${log.attemptTypeDisplay}'),
                    trailing: log.rating != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              log.rating!,
                              (_) => const Icon(Icons.star, size: 16, color: Colors.amber),
                            ),
                          )
                        : null,
                  ),
                );
              },
              childCount: _logs.length,
            ),
          ),
      ],
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _attemptIcon(String attemptType) {
    switch (attemptType) {
      case 'flash':
        return const CircleAvatar(
          backgroundColor: Colors.amber,
          child: Icon(Icons.flash_on, color: Colors.white),
        );
      case 'send':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white),
        );
      case 'project':
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.construction, color: Colors.white),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.replay, color: Colors.white),
        );
    }
  }
}
