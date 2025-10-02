import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../providers/auth_provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final NotificationRepository _notificationRepository = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationRepository.getNotifications(currentUser.id);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    try {
      await _notificationRepository.markAllAsRead(currentUser.id);
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'message':
        return Icons.message;
      case 'connection_request':
        return Icons.person_add;
      case 'connection_accepted':
        return Icons.person_add_alt_1;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'message':
        return AppTheme.primaryColor;
      case 'connection_request':
        return AppTheme.warningColor;
      case 'connection_accepted':
        return AppTheme.successColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Mark All as Read
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications, size: 24),
                  SizedBox(width: 12),
                  Text('Notifications', style: AppTheme.heading3),
                ],
              ),
              if (_notifications.any((n) => !n.read))
                TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text('Mark all as read'),
                ),
            ],
          ),
        ),

        // Notifications List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 64, color: AppTheme.textSecondary),
                            SizedBox(height: 16),
                            Text('No notifications yet', style: AppTheme.bodyMedium),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Dismissible(
                          key: Key(notification.id),
                          onDismissed: (_) => _markAsRead(notification.id),
                          background: Container(
                            color: AppTheme.successColor,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                          child: ListTile(
                            tileColor: notification.read ? null : AppTheme.surfaceColor,
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _getColorForType(notification.type).withValues(alpha: 0.2),
                                  child: Icon(
                                    _getIconForType(notification.type),
                                    color: _getColorForType(notification.type),
                                  ),
                                ),
                                if (!notification.read)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              notification.title,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: notification.read ? FontWeight.normal : FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (notification.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(notification.description!),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  notification.createdAt != null
                                      ? timeago.format(notification.createdAt!)
                                      : '',
                                  style: AppTheme.caption,
                                ),
                              ],
                            ),
                            onTap: () {
                              if (!notification.read) {
                                _markAsRead(notification.id);
                              }
                              // TODO: Navigate based on notification type
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
