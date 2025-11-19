import 'package:flutter/material.dart';

class FriendsSection extends StatelessWidget {
  const FriendsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const friends = [
      {'name': 'Sarah Chen', 'streak': '12 days', 'habit': 'Morning Exercise'},
      {'name': 'Mike Johnson', 'streak': '8 days', 'habit': 'Daily Exercise'},
      {'name': 'Emma Davis', 'streak': '5 days', 'habit': 'Reading Books'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Friends',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => const _AddFriendDialog(),
                  );
                },
                child: const Text('Add Friend'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: friends.map((f) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    theme.colorScheme.primary.withOpacity(0.15),
                    child: const Icon(Icons.person),
                  ),
                  title: Text(f['name'] as String),
                  subtitle:
                  Text('🔥 ${f['streak']} · ${f['habit']}'),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog();

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !text.contains('@')) {
      setState(() {
        _errorText = 'Please enter a valid email address';
      });
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent to $text (mock).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Friend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Send a friend request via email address.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Friend's Email",
              errorText: _errorText,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}