import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/habit_group.dart';
import '../../../services/firestore_service.dart';

class GroupHeader extends StatelessWidget {
  final HabitGroup group;

  const GroupHeader({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Back to Groups',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMembersButton(context),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              group.name, // DYNAMIC NAME
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildStreakAndStatus(theme),
            const SizedBox(height: 16),
            _buildLeaveOrDeleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakAndStatus(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔥 ${group.streak} Day Streak', // DYNAMIC STREAK
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, size: 14, color: Colors.greenAccent),
              const SizedBox(width: 4),
              Text(
                group.status == GroupStatus.onTrack ? 'On Track' : 'Passive',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersButton(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white24,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Group Members'),
            content: SizedBox(
              width: double.maxFinite,
              child: group.members.isEmpty
                  ? const Text('No members yet.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: group.members.length,
                      itemBuilder: (context, index) {
                        final uid = group.members[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(uid.isNotEmpty ? uid[0].toUpperCase() : '?'),
                          ),
                          title: Text('Member ${index + 1}'),
                          subtitle: Text('UID: ${uid.substring(0, uid.length > 8 ? 8 : uid.length)}...'),
                        );
                      },
                    ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.group, size: 16),
      label: const Text('Members', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildLeaveOrDeleteButton(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCreator = group.createdBy == currentUserId;

    if (currentUserId == null || !group.members.contains(currentUserId)) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleLeaveOrDelete(context, isCreator),
            icon: Icon(
              isCreator ? Icons.delete_outline : Icons.exit_to_app,
              size: 16,
            ),
            label: Text(isCreator ? 'Delete Group' : 'Leave Group'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLeaveOrDelete(BuildContext context, bool isCreator) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCreator ? 'Delete Group' : 'Leave Group'),
        content: Text(
          isCreator
              ? 'Are you sure you want to delete "${group.name}"? This action cannot be undone.'
              : 'Are you sure you want to leave "${group.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: isCreator ? Colors.red : null,
            ),
            child: Text(isCreator ? 'Delete' : 'Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      if (isCreator) {
        await firestoreService.deleteHabitGroup(group.id!);
        if (context.mounted) {
          Navigator.of(context).pop(); // Go back to groups screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Group deleted successfully')),
          );
        }
      } else {
        await firestoreService.leaveHabitGroup(group.id!);
        if (context.mounted) {
          Navigator.of(context).pop(); // Go back to groups screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Left group successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}