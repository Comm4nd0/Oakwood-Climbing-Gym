import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/support_ticket.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  final bool isStaff;
  const TicketDetailScreen({super.key, required this.ticketId, this.isStaff = false});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  SupportTicket? _ticket;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTicket() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final ticket = await api.getSupportTicket(widget.ticketId);
      setState(() {
        _ticket = ticket;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = 'Failed to load ticket details.';
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendReply() async {
    final body = _replyController.text.trim();
    if (body.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final api = context.read<ApiService>();
      await api.replySupportTicket(widget.ticketId, body);
      _replyController.clear();
      await _loadTicket();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reply: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _changeStatus(String newStatus) async {
    try {
      final api = context.read<ApiService>();
      await api.updateTicketStatus(widget.ticketId, newStatus);
      await _loadTicket();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${_statusLabel(newStatus)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('d MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  bool get _isClosed => _ticket?.status == 'closed';

  bool get _isStaff => widget.isStaff;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _ticket != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ticket!.subject,
                    style: const TextStyle(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _statusColor(_ticket!.status).withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _ticket!.statusDisplay,
                          style: TextStyle(
                            fontSize: 11,
                            color: _statusColor(_ticket!.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _ticket!.categoryDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : const Text('Ticket'),
        actions: [
          if (_ticket != null && _isStaff)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Change status',
              onSelected: _changeStatus,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'open', child: Text('Set Open')),
                const PopupMenuItem(value: 'in_progress', child: Text('Set In Progress')),
                const PopupMenuItem(value: 'resolved', child: Text('Set Resolved')),
                const PopupMenuItem(value: 'closed', child: Text('Set Closed')),
              ],
            ),
        ],
      ),
      body: _buildBody(),
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
              onPressed: _loadTicket,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_ticket == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Messages list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTicket,
            child: _ticket!.messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    itemCount: _ticket!.messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_ticket!.messages[index]);
                    },
                  ),
          ),
        ),

        // Reply input bar (hidden when closed)
        if (!_isClosed) _buildReplyBar(),
      ],
    );
  }

  Widget _buildMessageBubble(TicketMessage message) {
    final isStaff = message.isStaffReply;
    final alignment = isStaff ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final bubbleColor = isStaff
        ? Colors.grey.shade200
        : Theme.of(context).colorScheme.primary.withAlpha(25);
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isStaff ? 4 : 16),
      bottomRight: Radius.circular(isStaff ? 16 : 4),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Sender name + time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment:
                  isStaff ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (isStaff)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Staff',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
            ),
            child: Text(
              message.body,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _isSending ? null : _sendReply,
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
