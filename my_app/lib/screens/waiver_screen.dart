import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class WaiverScreen extends StatefulWidget {
  const WaiverScreen({super.key});

  @override
  State<WaiverScreen> createState() => _WaiverScreenState();
}

class _WaiverScreenState extends State<WaiverScreen> {
  List<Map<String, dynamic>> _waivers = [];
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
      final waivers = await api.getWaivers();
      setState(() {
        _waivers = waivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load waiver.';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiver')),
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

    if (_waivers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                'No waiver on file',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll need to complete a waiver before your first climb. Please speak to staff at the front desk.',
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
      itemCount: _waivers.length,
      itemBuilder: (context, index) {
        final w = _waivers[index];
        final isActive = w['is_active'] == true;
        final waiverType = w['waiver_type'] == 'under_18'
            ? 'Under 18 Guardian Waiver'
            : 'Adult Waiver';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isActive ? Icons.verified : Icons.warning_amber,
                      color: isActive ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        waiverType,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isActive ? Colors.green : Colors.orange)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Expired',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _WaiverDetail(
                  label: 'Signed',
                  value: _formatDate(w['signed_at']?.toString()),
                ),
                if (w['expires_at'] != null)
                  _WaiverDetail(
                    label: 'Expires',
                    value: _formatDate(w['expires_at']?.toString()),
                  ),
                _WaiverDetail(
                  label: 'Terms accepted',
                  value: w['accepts_terms'] == true ? 'Yes' : 'No',
                ),
                _WaiverDetail(
                  label: 'Photo consent',
                  value: w['accepts_photo_consent'] == true ? 'Yes' : 'No',
                ),
                if (w['has_medical_conditions'] == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medical_information,
                            size: 18, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Medical conditions noted on file',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Guardian info for under-18 waivers
                if (w['waiver_type'] == 'under_18' &&
                    w['guardian_name'] != null &&
                    w['guardian_name'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Guardian Details',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  _WaiverDetail(label: 'Name', value: w['guardian_name']),
                  if (w['guardian_phone']?.toString().isNotEmpty == true)
                    _WaiverDetail(label: 'Phone', value: w['guardian_phone']),
                  if (w['guardian_relationship']?.toString().isNotEmpty == true)
                    _WaiverDetail(
                        label: 'Relationship', value: w['guardian_relationship']),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WaiverDetail extends StatelessWidget {
  final String label;
  final String value;
  const _WaiverDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
