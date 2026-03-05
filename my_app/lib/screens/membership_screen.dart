import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  List<Map<String, dynamic>> _memberships = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final memberships = await api.getMemberships();
      setState(() {
        _memberships = memberships;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load memberships.';
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'frozen':
        return Colors.blue;
      case 'pending_cancellation':
        return Colors.orange;
      case 'cancelled':
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership')),
      body: RefreshIndicator(
        onRefresh: _load,
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
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_memberships.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.card_membership, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                'No active membership',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Visit the front desk or check our website to sign up for a membership plan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _memberships.length,
      itemBuilder: (context, index) {
        final m = _memberships[index];
        final status = m['status'] ?? 'unknown';
        final statusDisplay = m['status_display'] ?? status;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m['plan_name'] ?? 'Membership',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _statusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _DetailItem(
                  icon: Icons.attach_money,
                  label: 'Price',
                  value: '\u00a3${m['plan_price'] ?? '0.00'}/month',
                ),
                const SizedBox(height: 8),
                _DetailItem(
                  icon: Icons.calendar_today,
                  label: 'Started',
                  value: m['start_date'] ?? '-',
                ),
                if (m['end_date'] != null) ...[
                  const SizedBox(height: 8),
                  _DetailItem(
                    icon: Icons.event,
                    label: 'Ends',
                    value: m['end_date'],
                  ),
                ],
                if (m['frozen_until'] != null) ...[
                  const SizedBox(height: 8),
                  _DetailItem(
                    icon: Icons.ac_unit,
                    label: 'Frozen until',
                    value: m['frozen_until'],
                  ),
                ],
                const SizedBox(height: 8),
                _DetailItem(
                  icon: Icons.autorenew,
                  label: 'Auto-renew',
                  value: m['auto_renew'] == true ? 'Yes' : 'No',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
